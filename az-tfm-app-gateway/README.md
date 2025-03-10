<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage app gateway in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#-----------------------------------
# Public IP for application gateway
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.sku.tier == "Standard" ? "Dynamic" : "Static"
  sku                 = var.sku.tier == "Standard" ? "Basic" : "Standard"
  domain_name_label   = var.domain_name_label
  tags                = var.tags
}

#----------------------------------------------
# Application Gateway with all optional blocks
#----------------------------------------------
resource "azurerm_application_gateway" "main" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  enable_http2       = var.enable_http2
  zones              = var.zones
  firewall_policy_id = var.firewall_policy_id != null ? var.firewall_policy_id : null
  tags               = var.tags

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.autoscale_configuration == null ? var.sku.capacity : null
  }
  #----------------------------------------------------------
  # Backend Address Pool Configuration (Required)
  #----------------------------------------------------------
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }
  #----------------------------------------------------------
  # Backend HTTP Settings (Required)
  #----------------------------------------------------------
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      affinity_cookie_name                = lookup(backend_http_settings.value, "affinity_cookie_name", null)
      path                                = lookup(backend_http_settings.value, "path", "/")
      port                                = backend_http_settings.value.enable_https ? 443 : 80
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      protocol                            = backend_http_settings.value.enable_https ? "Https" : "Http"
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 30)
      host_name                           = backend_http_settings.value.pick_host_name_from_backend_address == false ? lookup(backend_http_settings.value, "host_name") : null
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)

      dynamic "authentication_certificate" {
        for_each = backend_http_settings.value.authentication_certificate[*]
        content {
          name = authentication_certificate.value.name
        }
      }

      trusted_root_certificate_names = lookup(backend_http_settings.value, "trusted_root_certificate_names", null)

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining[*]
        content {
          enabled           = connection_draining.value.enable_connection_draining
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address            = var.private_ip_address != null ? var.private_ip_address : null
    private_ip_address_allocation = var.private_ip_address != null ? "Static" : null
    subnet_id                     = var.private_ip_address != null ? data.azurerm_subnet.snet.id : null
  }

  frontend_port {
    name = "${var.frontend_port_name}-http"
    port = 80
  }

  frontend_port {
    name = "${var.frontend_port_name}-https"
    port = 443
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = data.azurerm_subnet.snet.id
  }

  #----------------------------------------------------------
  # HTTP Listener Configuration (Required)
  #----------------------------------------------------------
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = var.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.ssl_certificate_name == null ? "${var.frontend_port_name}-http" : "${var.frontend_port_name}-https"
      host_name                      = lookup(http_listener.value, "host_name", null)
      host_names                     = lookup(http_listener.value, "host_names", null)
      protocol                       = http_listener.value.ssl_certificate_name == null ? "Http" : "Https"
      require_sni                    = http_listener.value.ssl_certificate_name != null ? http_listener.value.require_sni : null
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      firewall_policy_id             = http_listener.value.firewall_policy_id
      ssl_profile_name               = http_listener.value.ssl_profile_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configuration != null ? lookup(http_listener.value, "custom_error_configuration", {}) : []
        content {
          custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
          status_code           = lookup(custom_error_configuration.value, "status_code", null)
        }
      }
    }
  }
  #----------------------------------------------------------
  # Request routing rules Configuration (Required)
  #----------------------------------------------------------
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      rule_type                   = lookup(request_routing_rule.value, "rule_type", "Basic")
      priority                    = lookup(request_routing_rule.value, "priority", null)
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = request_routing_rule.value.redirect_configuration_name == null ? request_routing_rule.value.backend_address_pool_name : null
      backend_http_settings_name  = request_routing_rule.value.redirect_configuration_name == null ? request_routing_rule.value.backend_http_settings_name : null
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }

  dynamic "global" {
    for_each = var.global_configuration != null ? [var.global_configuration] : []
    content {
      request_buffering_enabled  = false
      response_buffering_enabled = false
    }
  }

  #---------------------------------------------------------------
  # Identity block Configuration (Optional)
  # A list with a single user managed identity id to be assigned
  #---------------------------------------------------------------
  dynamic "identity" {
    for_each = var.identity_ids != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  #----------------------------------------------------------
  # Trusted Root SSL Certificate Configuration (Optional)
  #----------------------------------------------------------
  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = filebase64(trusted_root_certificate.value.data)
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      min_capacity = lookup(autoscale_configuration.value, "min_capacity")
      max_capacity = lookup(autoscale_configuration.value, "max_capacity")
    }
  }

  #----------------------------------------------------------
  # Authentication SSL Certificate Configuration (Optional)
  #----------------------------------------------------------
  dynamic "authentication_certificate" {
    for_each = var.authentication_certificates != null ? var.authentication_certificates : []
    content {
      name = authentication_certificate.value.name
      data = filebase64(authentication_certificate.value.data)
    }
  }

  dynamic "ssl_profile" {
    for_each = var.ssl_profiles != null ? var.ssl_profiles : []
    content {
      name                                 = ssl_profile.value.name
      trusted_client_certificate_names     = ssl_profile.value.trusted_client_certificate_names
      verify_client_certificate_revocation = ssl_profile.value.verify_client_certificate_revocation
      verify_client_cert_issuer_dn         = "OCSP"
      dynamic "ssl_policy" {
        for_each = var.ssl_policy != null ? [var.ssl_policy] : []
        content {
          disabled_protocols   = var.ssl_policy.policy_type == null && var.ssl_policy.policy_name == null ? var.ssl_policy.disabled_protocols : null
          policy_type          = lookup(var.ssl_policy, "policy_type", "Predefined")
          policy_name          = var.ssl_policy.policy_type == "Predefined" ? var.ssl_policy.policy_name : null
          cipher_suites        = var.ssl_policy.policy_type == "Custom" ? var.ssl_policy.cipher_suites : null
          min_protocol_version = var.ssl_policy.min_protocol_version
        }
      }
    }
  }

  #----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # SSL Policy for Application Gateway (Optional)
  # Application Gateway has three predefined security policies to get the appropriate level of security
  # AppGwSslPolicy20150501 - MinProtocolVersion(TLSv1_0), AppGwSslPolicy20170401 - MinProtocolVersion(TLSv1_1), AppGwSslPolicy20170401S - MinProtocolVersion(TLSv1_2)
  #----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      disabled_protocols   = var.ssl_policy.policy_type == null && var.ssl_policy.policy_name == null ? var.ssl_policy.disabled_protocols : null
      policy_type          = lookup(var.ssl_policy, "policy_type", "Predefined")
      policy_name          = var.ssl_policy.policy_type == "Predefined" ? var.ssl_policy.policy_name : null
      cipher_suites        = var.ssl_policy.policy_type == "Custom" ? var.ssl_policy.cipher_suites : null
      min_protocol_version = var.ssl_policy.min_protocol_version
    }
  }

  #----------------------------------------------------------
  # Health Probe (Optional)
  #----------------------------------------------------------
  dynamic "probe" {
    for_each = var.health_probes
    content {
      name                                      = probe.value.name
      host                                      = lookup(probe.value, "host", "127.0.0.1")
      interval                                  = lookup(probe.value, "interval", 30)
      protocol                                  = probe.value.port == 443 ? "Https" : "Http"
      path                                      = lookup(probe.value, "path", "/")
      timeout                                   = lookup(probe.value, "timeout", 30)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", 3)
      port                                      = lookup(probe.value, "port", 443)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
      minimum_servers                           = lookup(probe.value, "minimum_servers", 0)
    }
  }

  #----------------------------------------------------------
  # SSL Certificate (.pfx) Configuration (Optional)
  #----------------------------------------------------------
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.key_vault_secret_id == null ? filebase64(ssl_certificate.value.data) : null
      password            = ssl_certificate.value.key_vault_secret_id == null ? ssl_certificate.value.password : null
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }



  #----------------------------------------------------------
  # URL Path Mappings (Optional)
  #----------------------------------------------------------
  dynamic "url_path_map" {
    for_each = var.url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_redirect_configuration_name == null ? url_path_map.value.default_backend_address_pool_name : null
      default_backend_http_settings_name  = url_path_map.value.default_redirect_configuration_name == null ? url_path_map.value.default_backend_http_settings_name : null
      default_redirect_configuration_name = lookup(url_path_map.value, "default_redirect_configuration_name", null)
      default_rewrite_rule_set_name       = lookup(url_path_map.value, "default_rewrite_rule_set_name", null)

      dynamic "path_rule" {
        for_each = lookup(url_path_map.value, "path_rules")
        content {
          name                        = path_rule.value.name
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          paths                       = flatten(path_rule.value.paths)
          redirect_configuration_name = lookup(path_rule.value, "redirect_configuration_name", null)
          rewrite_rule_set_name       = lookup(path_rule.value, "rewrite_rule_set_name", null)
          firewall_policy_id          = lookup(path_rule.value, "firewall_policy_id", null)
        }
      }
    }
  }

  #----------------------------------------------------------
  # Redirect Configuration (Optional)
  #----------------------------------------------------------
  dynamic "redirect_configuration" {
    for_each = var.redirect_configuration
    content {
      name                 = lookup(redirect_configuration.value, "name", null)
      redirect_type        = lookup(redirect_configuration.value, "redirect_type", "Permanent")
      target_listener_name = lookup(redirect_configuration.value, "target_listener_name", null)
      target_url           = lookup(redirect_configuration.value, "target_url", null)
      include_path         = lookup(redirect_configuration.value, "include_path", "true")
      include_query_string = lookup(redirect_configuration.value, "include_query_string", "true")
    }
  }

  #----------------------------------------------------------
  # Custom error configuration (Optional)
  #----------------------------------------------------------
  dynamic "custom_error_configuration" {
    for_each = var.custom_error_configuration
    content {
      custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
      status_code           = lookup(custom_error_configuration.value, "status_code", null)
    }
  }

  #----------------------------------------------------------
  # Rewrite Rules Set configuration (Optional)
  #----------------------------------------------------------
  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_set
    content {
      name = var.rewrite_rule_set.name

      dynamic "rewrite_rule" {
        for_each = lookup(var.rewrite_rule_set, "rewrite_rules", [])
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = lookup(rewrite_rule_set.value, "condition", [])
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = lookup(rewrite_rule.value, "request_header_configuration", [])
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = lookup(rewrite_rule.value, "response_header_configuration", [])
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = lookup(rewrite_rule.value, "url", [])
            content {
              path         = url.value.path
              query_string = url.value.query_string
              reroute      = url.value.reroute
            }
          }
        }
      }
    }
  }

  #----------------------------------------------------------
  # Web application Firewall (WAF) configuration (Optional)
  # Tier to be either “WAF” or “WAF V2”
  #----------------------------------------------------------
  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = true
      firewall_mode            = lookup(waf_configuration.value, "firewall_mode", "Detection")
      rule_set_type            = "OWASP"
      rule_set_version         = lookup(waf_configuration.value, "rule_set_version", "3.1")
      file_upload_limit_mb     = lookup(waf_configuration.value, "file_upload_limit_mb", 100)
      request_body_check       = lookup(waf_configuration.value, "request_body_check", true)
      max_request_body_size_kb = lookup(waf_configuration.value, "max_request_body_size_kb", 128)

      dynamic "disabled_rule_group" {
        for_each = waf_configuration.value.disabled_rule_group
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }

      dynamic "exclusion" {
        for_each = waf_configuration.value.exclusion
        content {
          match_variable          = exclusion.value.match_variable
          selector_match_operator = exclusion.value.selector_match_operator
          selector                = exclusion.value.selector
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_gateway_name"></a> [app\_gateway\_name](#input\_app\_gateway\_name) | The name of the application gateway | `string` | `""` | no |
| <a name="input_authentication_certificates"></a> [authentication\_certificates](#input\_authentication\_certificates) | Authentication certificates to allow the backend with Azure Application Gateway | <pre>list(object({<br>    name = string<br>    data = string<br>  }))</pre> | `[]` | no |
| <a name="input_autoscale_configuration"></a> [autoscale\_configuration](#input\_autoscale\_configuration) | Minimum or Maximum capacity for autoscaling. Accepted values are for Minimum in the range 0 to 100 and for Maximum in the range 2 to 125 | <pre>object({<br>    min_capacity = number<br>    max_capacity = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | List of backend address pools | <pre>list(object({<br>    name         = string<br>    fqdns        = optional(list(string))<br>    ip_addresses = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | List of backend HTTP settings. | <pre>list(object({<br>    name                                = string<br>    cookie_based_affinity               = string<br>    affinity_cookie_name                = optional(string)<br>    path                                = optional(string)<br>    enable_https                        = bool<br>    probe_name                          = optional(string)<br>    request_timeout                     = number<br>    host_name                           = optional(string)<br>    pick_host_name_from_backend_address = optional(bool)<br>    authentication_certificate = optional(object({<br>      name = string<br>    }))<br>    trusted_root_certificate_names = optional(list(string))<br>    connection_draining = optional(object({<br>      enable_connection_draining = bool<br>      drain_timeout_sec          = number<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_custom_error_configuration"></a> [custom\_error\_configuration](#input\_custom\_error\_configuration) | Global level custom error configuration for application gateway | `list(map(string))` | `[]` | no |
| <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label) | Label for the Domain Name. Will be used to make up the FQDN. | `any` | `null` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Is HTTP2 enabled on the application gateway resource? | `bool` | `false` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | The ID of the Web Application Firewall Policy which can be associated with app gateway | `any` | `null` | no |
| <a name="input_frontend_ip_configuration_name"></a> [frontend\_ip\_configuration\_name](#input\_frontend\_ip\_configuration\_name) | The name of the frontend ip configuration | `string` | `""` | no |
| <a name="input_frontend_port_name"></a> [frontend\_port\_name](#input\_frontend\_port\_name) | The name of the frontend port | `string` | `""` | no |
| <a name="input_gateway_ip_configuration_name"></a> [gateway\_ip\_configuration\_name](#input\_gateway\_ip\_configuration\_name) | The name of the gateway ip configuration | `string` | `""` | no |
| <a name="input_global_configuration"></a> [global\_configuration](#input\_global\_configuration) | Global configuration for Application Gateway | <pre>object({<br>    request_buffering_enabled  = optional(bool)<br>    response_buffering_enabled = optional(bool)<br>  })</pre> | `{}` | no |
| <a name="input_health_probes"></a> [health\_probes](#input\_health\_probes) | List of Health probes used to test backend pools health. | <pre>list(object({<br>    name                                      = string<br>    host                                      = string<br>    interval                                  = number<br>    path                                      = string<br>    timeout                                   = number<br>    unhealthy_threshold                       = number<br>    port                                      = optional(number)<br>    pick_host_name_from_backend_http_settings = optional(bool)<br>    minimum_servers                           = optional(number)<br>    match = optional(object({<br>      body        = optional(string)<br>      status_code = optional(list(string))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | List of HTTP/HTTPS listeners. SSL Certificate name is required | <pre>list(object({<br>    name                 = string<br>    host_name            = optional(string)<br>    host_names           = optional(list(string))<br>    require_sni          = optional(bool)<br>    ssl_certificate_name = optional(string)<br>    firewall_policy_id   = optional(string)<br>    ssl_profile_name     = optional(string)<br>    custom_error_configuration = optional(list(object({<br>      status_code           = string<br>      custom_error_page_url = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list with a single user managed identity id to be assigned to the Application Gateway | `any` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `""` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | Private IP Address to assign to the Load Balancer. | `any` | `null` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Public IP name for Application Gateway | `string` | `""` | no |
| <a name="input_redirect_configuration"></a> [redirect\_configuration](#input\_redirect\_configuration) | list of maps for redirect configurations | `list(map(string))` | `[]` | no |
| <a name="input_request_routing_rules"></a> [request\_routing\_rules](#input\_request\_routing\_rules) | List of Request routing rules to be used for listeners. | <pre>list(object({<br>    name                        = string<br>    rule_type                   = string<br>    http_listener_name          = string<br>    priority                    = optional(number)<br>    backend_address_pool_name   = optional(string)<br>    backend_http_settings_name  = optional(string)<br>    redirect_configuration_name = optional(string)<br>    rewrite_rule_set_name       = optional(string)<br>    url_path_map_name           = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | A container that holds related resources for an Azure solution | `string` | `""` | no |
| <a name="input_rewrite_rule_set"></a> [rewrite\_rule\_set](#input\_rewrite\_rule\_set) | List of rewrite rule set including rewrite rules | `any` | `[]` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The sku pricing model of v1 and v2 | <pre>object({<br>    name     = string<br>    tier     = string<br>    capacity = optional(number)<br>  })</pre> | n/a | yes |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | List of SSL certificates data for Application gateway | <pre>list(object({<br>    name                = string<br>    data                = optional(string)<br>    password            = optional(string)<br>    key_vault_secret_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Application Gateway SSL configuration | <pre>object({<br>    disabled_protocols   = optional(list(string))<br>    policy_type          = optional(string)<br>    policy_name          = optional(string)<br>    cipher_suites        = optional(list(string))<br>    min_protocol_version = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_ssl_profiles"></a> [ssl\_profiles](#input\_ssl\_profiles) | SSL profiles to allow the backend with Azure Application Gateway | <pre>list(object({<br>    name                                 = string<br>    trusted_client_certificate_names     = optional(list(string))<br>    verify_client_certificate_revocation = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the hub storage account to store logs | `any` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to use in VM scale set | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_trusted_root_certificates"></a> [trusted\_root\_certificates](#input\_trusted\_root\_certificates) | Trusted root certificates to allow the backend with Azure Application Gateway | <pre>list(object({<br>    name = string<br>    data = string<br>  }))</pre> | `[]` | no |
| <a name="input_url_path_maps"></a> [url\_path\_maps](#input\_url\_path\_maps) | List of URL path maps associated to path-based rules. | <pre>list(object({<br>    name                                = string<br>    default_backend_http_settings_name  = optional(string)<br>    default_backend_address_pool_name   = optional(string)<br>    default_redirect_configuration_name = optional(string)<br>    default_rewrite_rule_set_name       = optional(string)<br>    path_rules = list(object({<br>      name                        = string<br>      backend_address_pool_name   = optional(string)<br>      backend_http_settings_name  = optional(string)<br>      paths                       = list(string)<br>      redirect_configuration_name = optional(string)<br>      rewrite_rule_set_name       = optional(string)<br>      firewall_policy_id          = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network | `string` | `""` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | Web Application Firewall support for your Azure Application Gateway | <pre>object({<br>    firewall_mode            = string<br>    rule_set_version         = string<br>    file_upload_limit_mb     = optional(number)<br>    request_body_check       = optional(bool)<br>    max_request_body_size_kb = optional(number)<br>    disabled_rule_group = optional(list(object({<br>      rule_group_name = string<br>      rules           = optional(list(string))<br>    })))<br>    exclusion = optional(list(object({<br>      match_variable          = string<br>      selector_match_operator = optional(string)<br>      selector                = optional(string)<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | A collection of availability zones to spread the Application Gateway over. | `list(string)` | `[]` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_gateway_name"></a> [app\_gateway\_name](#output\_app\_gateway\_name) | The Name of the Application Gateway |
| <a name="output_application_gateway_id"></a> [application\_gateway\_id](#output\_application\_gateway\_id) | The ID of the Application Gateway |
| <a name="output_authentication_certificate_id"></a> [authentication\_certificate\_id](#output\_authentication\_certificate\_id) | The ID of the Authentication Certificate |
| <a name="output_backend_address_pool_id"></a> [backend\_address\_pool\_id](#output\_backend\_address\_pool\_id) | The ID of the Backend Address Pool |
| <a name="output_backend_address_pool_name"></a> [backend\_address\_pool\_name](#output\_backend\_address\_pool\_name) | The Name of the Backend Address Pool |
| <a name="output_backend_http_settings_id"></a> [backend\_http\_settings\_id](#output\_backend\_http\_settings\_id) | The ID of the Backend HTTP Settings Configuration |
| <a name="output_backend_http_settings_name"></a> [backend\_http\_settings\_name](#output\_backend\_http\_settings\_name) | The Name of the Backend HTTP Settings Configuration |
| <a name="output_backend_http_settings_probe_id"></a> [backend\_http\_settings\_probe\_id](#output\_backend\_http\_settings\_probe\_id) | The ID of the Backend HTTP Settings Configuration associated Probe |
| <a name="output_custom_error_configuration_id"></a> [custom\_error\_configuration\_id](#output\_custom\_error\_configuration\_id) | The ID of the Custom Error Configuration |
| <a name="output_frontend_ip_configuration_id"></a> [frontend\_ip\_configuration\_id](#output\_frontend\_ip\_configuration\_id) | The ID of the Frontend IP Configuration |
| <a name="output_frontend_ip_configuration_name"></a> [frontend\_ip\_configuration\_name](#output\_frontend\_ip\_configuration\_name) | The Name of the Frontend IP Configuration |
| <a name="output_frontend_port_id"></a> [frontend\_port\_id](#output\_frontend\_port\_id) | The ID of the Frontend Port |
| <a name="output_gateway_ip_configuration_id"></a> [gateway\_ip\_configuration\_id](#output\_gateway\_ip\_configuration\_id) | The ID of the Gateway IP Configuration |
| <a name="output_gateway_ip_configuration_name"></a> [gateway\_ip\_configuration\_name](#output\_gateway\_ip\_configuration\_name) | The Name of the Gateway IP Configuration |
| <a name="output_http_listener_frontend_ip_configuration_id"></a> [http\_listener\_frontend\_ip\_configuration\_id](#output\_http\_listener\_frontend\_ip\_configuration\_id) | The ID of the associated Frontend Configuration |
| <a name="output_http_listener_frontend_port_id"></a> [http\_listener\_frontend\_port\_id](#output\_http\_listener\_frontend\_port\_id) | The ID of the associated Frontend Port |
| <a name="output_http_listener_id"></a> [http\_listener\_id](#output\_http\_listener\_id) | The ID of the HTTP Listener |
| <a name="output_http_listener_name"></a> [http\_listener\_name](#output\_http\_listener\_name) | The Name of the HTTP Listener |
| <a name="output_http_listener_ssl_certificate_id"></a> [http\_listener\_ssl\_certificate\_id](#output\_http\_listener\_ssl\_certificate\_id) | The ID of the associated SSL Certificate |
| <a name="output_probe_id"></a> [probe\_id](#output\_probe\_id) | The ID of the health Probe |
| <a name="output_redirect_configuration_id"></a> [redirect\_configuration\_id](#output\_redirect\_configuration\_id) | The ID of the Redirect Configuration |
| <a name="output_request_routing_rule_backend_address_pool_id"></a> [request\_routing\_rule\_backend\_address\_pool\_id](#output\_request\_routing\_rule\_backend\_address\_pool\_id) | The ID of the Request Routing Rule associated Backend Address Pool |
| <a name="output_request_routing_rule_backend_http_settings_id"></a> [request\_routing\_rule\_backend\_http\_settings\_id](#output\_request\_routing\_rule\_backend\_http\_settings\_id) | The ID of the Request Routing Rule associated Backend HTTP Settings Configuration |
| <a name="output_request_routing_rule_http_listener_id"></a> [request\_routing\_rule\_http\_listener\_id](#output\_request\_routing\_rule\_http\_listener\_id) | The ID of the Request Routing Rule associated HTTP Listener |
| <a name="output_request_routing_rule_id"></a> [request\_routing\_rule\_id](#output\_request\_routing\_rule\_id) | The ID of the Request Routing Rule |
| <a name="output_request_routing_rule_name"></a> [request\_routing\_rule\_name](#output\_request\_routing\_rule\_name) | The Name of the Request Routing Rule |
| <a name="output_request_routing_rule_redirect_configuration_id"></a> [request\_routing\_rule\_redirect\_configuration\_id](#output\_request\_routing\_rule\_redirect\_configuration\_id) | The ID of the Request Routing Rule associated Redirect Configuration |
| <a name="output_request_routing_rule_rewrite_rule_set_id"></a> [request\_routing\_rule\_rewrite\_rule\_set\_id](#output\_request\_routing\_rule\_rewrite\_rule\_set\_id) | The ID of the Request Routing Rule associated Rewrite Rule Set |
| <a name="output_request_routing_rule_url_path_map_id"></a> [request\_routing\_rule\_url\_path\_map\_id](#output\_request\_routing\_rule\_url\_path\_map\_id) | The ID of the Request Routing Rule associated URL Path Map |
| <a name="output_rewrite_rule_set_id"></a> [rewrite\_rule\_set\_id](#output\_rewrite\_rule\_set\_id) | The ID of the Rewrite Rule Set |
| <a name="output_ssl_certificate_id"></a> [ssl\_certificate\_id](#output\_ssl\_certificate\_id) | The ID of the SSL Certificate |
| <a name="output_ssl_certificate_public_cert_data"></a> [ssl\_certificate\_public\_cert\_data](#output\_ssl\_certificate\_public\_cert\_data) | The Public Certificate Data associated with the SSL Certificate |
| <a name="output_url_path_map_default_backend_address_pool_id"></a> [url\_path\_map\_default\_backend\_address\_pool\_id](#output\_url\_path\_map\_default\_backend\_address\_pool\_id) | The ID of the Default Backend Address Pool associated with URL Path Map |
| <a name="output_url_path_map_default_backend_http_settings_id"></a> [url\_path\_map\_default\_backend\_http\_settings\_id](#output\_url\_path\_map\_default\_backend\_http\_settings\_id) | The ID of the Default Backend HTTP Settings Collection associated with URL Path Map |
| <a name="output_url_path_map_default_redirect_configuration_id"></a> [url\_path\_map\_default\_redirect\_configuration\_id](#output\_url\_path\_map\_default\_redirect\_configuration\_id) | The ID of the Default Redirect Configuration associated with URL Path Map |
| <a name="output_url_path_map_id"></a> [url\_path\_map\_id](#output\_url\_path\_map\_id) | The ID of the URL Path Map |

#### The following resources are created by this module:


- resource.azurerm_application_gateway.main (/usr/agent/azp/_work/1/s/amn-az-tfm-app-gateway/main.tf#17)
- resource.azurerm_public_ip.pip (/usr/agent/azp/_work/1/s/amn-az-tfm-app-gateway/main.tf#4)
- data source.azurerm_storage_account.storeacc (/usr/agent/azp/_work/1/s/amn-az-tfm-app-gateway/data.tf#12)
- data source.azurerm_subnet.snet (/usr/agent/azp/_work/1/s/amn-az-tfm-app-gateway/data.tf#6)
- data source.azurerm_virtual_network.vnet (/usr/agent/azp/_work/1/s/amn-az-tfm-app-gateway/data.tf#1)


## Example Scenario

Create application gateway <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create virtual network and subnets<br /> - Create public ip address<br /> - Create user assigned identity<br /> - Create application gateway

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  app_gateway_suffix    = "appgw"
  vnet_suffix           = "vnet"
  environment_suffix    = "t01"
  us_region_abbreviations = {
    centralus      = "cus"
    eastus         = "eus"
    eastus2        = "eus2"
    westus         = "wus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westcentralus  = "wcus"
    westus2        = "wus2"
  }
  region_abbreviation = local.us_region_abbreviations[var.location]

  # resource_group_name   = "co-wus2-amnoneshared-rg-t02"
  resource_group_name            = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  vnet_name                      = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suffix}-${local.environment_suffix}"
  subnet_name                    = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-subnet"
  app_gateway_name               = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-${local.environment_suffix}"
  public_ip_name                 = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-pip"
  frontend_port_name             = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-feport"
  frontend_ip_configuration_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-feip"
  gateway_ip_configuration_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-gwipc"
  user_assigned_identity_name    = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-uaid-${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = module.rg.resource_group_name
  location            = var.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "snet" {
  #checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = local.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.0.0/24"]
}

module "user_assigned_identity" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                  = [module.rg]
  source                      = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-user-assigned-identity?ref=v1.0.0"
  create_resource_group       = false
  resource_group_name         = local.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.user_assigned_identity_name
  tags                        = var.tags
}

module "application-gateway" {
  #checkov:skip=CKV_AZURE_218: "Ensure Application Gateway defines secure protocols for in transit communication"
  depends_on                     = [azurerm_subnet.snet, module.rg, module.user_assigned_identity]
  source                         = "../"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  virtual_network_name           = local.vnet_name
  subnet_name                    = local.subnet_name
  enable_http2                   = true
  app_gateway_name               = local.app_gateway_name
  public_ip_name                 = local.public_ip_name
  sku                            = var.sku
  backend_address_pools          = var.backend_address_pools
  frontend_port_name             = local.frontend_port_name
  gateway_ip_configuration_name  = local.gateway_ip_configuration_name
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  backend_http_settings          = var.backend_http_settings
  http_listeners                 = var.http_listeners
  request_routing_rules          = var.request_routing_rules
  identity_ids                   = ["${module.user_assigned_identity.mi_id}"]
  tags                           = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location = "westus2"
tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "Platform Services",
  product         = "Platform Services",
  amnonecomponent = "shared",
  role            = "infrastructure-tf-unit-test",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}

subnets = {
  mgnt_subnet1 = {
    subnet_name           = "snet-management1"
    subnet_address_prefix = ["10.0.1.0/24"]
  }
}
sku = {
  name     = "Standard_v2"
  tier     = "Standard_v2"
  capacity = 1
}
backend_address_pools = [
  {
    name = "appgw-testgateway-wus2-bapool01"
  }
]

backend_http_settings = [
  {
    name                                = "appgw-testgateway-wus2-be-http-set1"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    enable_https                        = false
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    connection_draining = {
      enable_connection_draining = true
      drain_timeout_sec          = 300
    }
  }
]

http_listeners = [
  {
    name                 = "appgw-testgateway-wus2-be-htln01"
    ssl_certificate_name = null
    firewall_policy_id   = null
    ssl_profile_name     = null
  }
]

request_routing_rules = [
  {
    name                       = "appgw-testgateway-wus2-be-rqrt"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "appgw-testgateway-wus2-be-htln01"
    backend_address_pool_name  = "appgw-testgateway-wus2-bapool01"
    backend_http_settings_name = "appgw-testgateway-wus2-be-http-set1"
  }
]
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->