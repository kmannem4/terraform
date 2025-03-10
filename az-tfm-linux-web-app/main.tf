#---------------------------------
# Local declarations
#---------------------------------

locals {
  is_network_config_required                   = { for k, v in var.linux_web_app_service_vars : k => v if lookup(v, "is_network_config_required", false) == true }
  is_virtual_network_swift_connection_required = { for k, v in var.linux_web_app_service_vars : k => v if lookup(v, "is_virtual_network_swift_connection_required", false) == true }
  is_appinsights_instrumentation_key_required  = { for k, v in var.linux_web_app_service_vars : k => v if lookup(v, "is_appinsights_instrumentation_key_required", false) == true }
  is_kv_access_policy_required                 = { for k, v in var.linux_web_app_service_vars : k => v if lookup(v, "is_kv_access_policy_required", false) == true }
  is_log_analytics_workspace_id_required       = { for k, v in var.linux_web_app_service_vars : k => v if lookup(v, "is_log_analytics_workspace_id_required", false) == true }
}


#-------------------------------------------------
# Linux Web App Service Creation
#-------------------------------------------------

resource "azurerm_linux_web_app" "linux_web_app" {
  for_each                  = var.linux_web_app_service_vars
  name                      = each.value.linux_web_app_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  service_plan_id           = data.azurerm_service_plan.app_service_plan[each.key].id
  tags                      = var.tags
  app_settings              = each.value.is_appinsights_instrumentation_key_required ? merge({ "APPINSIGHTS_INSTRUMENTATIONKEY" = data.azurerm_application_insights.application_insights[each.key].connection_string }, each.value.web_app_settings) : each.value.web_app_settings
  https_only                = each.value.web_app_https_only
  enabled                   = each.value.is_web_app_enabled
  virtual_network_subnet_id = each.value.is_virtual_network_swift_connection_required ? null : each.value.is_network_config_required ? data.azurerm_subnet.subnet[each.key].id : null
  dynamic "site_config" {
    for_each = each.value.web_app_site_config != null ? [each.value.web_app_site_config] : null
    content {
      always_on           = site_config.value.site_config_always_on
      ftps_state          = site_config.value.site_config_ftps_state
      minimum_tls_version = site_config.value.site_config_minimum_tls_version
      http2_enabled       = site_config.value.site_config_http2_enabled
      use_32_bit_worker   = site_config.value.site_config_use_32_bit_worker
      dynamic "cors" {
        for_each = site_config.value.site_config_cors != null ? site_config.value.site_config_cors : null
        content {
          allowed_origins     = cors.value.site_config_cors_allowed_origins
          support_credentials = cors.value.site_config_cors_support_credentials
        }
      }
      dynamic "application_stack" {
        for_each = site_config.value.application_stack != null ? [site_config.value.application_stack] : []
        content {
          docker_image_name = application_stack.value.docker_image_name != null ? application_stack.value.docker_image_name : null
          docker_registry_url = application_stack.value.docker_registry_url != null ? application_stack.value.docker_registry_url : null
          docker_registry_username = application_stack.value.docker_registry_username != null ? application_stack.value.docker_registry_username : null
          docker_registry_password = application_stack.value.docker_registry_password != null ? application_stack.value.docker_registry_password : null
          dotnet_version      = application_stack.value.dotnet_version != null ? application_stack.value.dotnet_version : null
          java_version        = application_stack.value.java_version != null ? application_stack.value.java_version : null
          java_server         = application_stack.value.java_server != null ? application_stack.value.java_server : null
          java_server_version = application_stack.value.java_server_version != null ? application_stack.value.java_server_version : null
          node_version        = application_stack.value.node_version != null ? application_stack.value.node_version : null
          php_version         = application_stack.value.php_version != null ? application_stack.value.php_version : null
          python_version      = application_stack.value.python_version != null ? application_stack.value.python_version : null
          ruby_version        = application_stack.value.ruby_version != null ? application_stack.value.ruby_version : null
          go_version          = application_stack.value.go_version != null ? application_stack.value.go_version : null
        }
      }

      dynamic "ip_restriction" {
        for_each = site_config.value.web_app_ip_restriction != null ? site_config.value.web_app_ip_restriction : {}
        content {
          action                    = ip_restriction.value.web_app_ip_restriction_action
          name                      = ip_restriction.value.web_app_ip_restriction_name
          priority                  = ip_restriction.value.web_app_ip_restriction_priority
          ip_address                = ip_restriction.value.web_app_ip_restriction_ip_address
          service_tag               = ip_restriction.value.web_app_ip_restriction_service_tag
          virtual_network_subnet_id = ip_restriction.value.web_app_ip_restriction_virtual_network_subnet_id
          dynamic "headers" {
            for_each = ip_restriction.value.web_app_ip_restriction_headers != null ? [ip_restriction.value.web_app_ip_restriction_headers] : []
            content {
              x_azure_fdid      = headers.value.headers_x_azure_fdid
              x_fd_health_probe = headers.value.headers_x_fd_health_probe
              x_forwarded_for   = headers.value.headers_x_forwarded_for
              x_forwarded_host  = headers.value.headers_x_forwarded_host
            }
          }
        }
      }
    }
  }

  dynamic "logs" {
    for_each = each.value.logs == null ? null : each.value.logs
    content {
      dynamic "application_logs" {
        for_each = logs.value.application_logs != null ? logs.value.application_logs : []
        content {
          file_system_level = application_logs.value.file_system_level
        }
      }
    }
  }

  dynamic "identity" {
    for_each = each.value.web_app_identity != null ? [1] : []
    content {
      type = each.value.web_app_identity.web_app_identity_type
    }
  }

  dynamic "connection_string" {
    for_each = each.value.connection_strings != null ? each.value.connection_strings : {}
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

}

#-------------------------------------------------
# Linux Web App Service Virtual Network Swift Connection
#-------------------------------------------------

resource "azurerm_app_service_virtual_network_swift_connection" "virtual_network_swift_connection" {
  for_each       = local.is_virtual_network_swift_connection_required
  app_service_id = azurerm_linux_web_app.linux_web_app[each.key].id
  subnet_id      = data.azurerm_subnet.subnet[each.key].id
}

#-------------------------------------------------
# Linux Web App Service Key Vault Access Policy
#-------------------------------------------------

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  for_each           = local.is_kv_access_policy_required
  key_vault_id       = data.azurerm_key_vault.key_vault[each.key].id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_linux_web_app.linux_web_app[each.key].identity[0].principal_id
  secret_permissions = each.value.secret_permissions != null || each.value.secret_permissions != [] ? each.value.secret_permissions : []
  key_permissions    = each.value.key_permissions != null || each.value.key_permissions != [] ? each.value.key_permissions : []
}

#---------------------------------------------------------------
# Module to create a diagnostic setting for the web app
#---------------------------------------------------------------
module "diagnostic" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  for_each                       = local.is_log_analytics_workspace_id_required
  depends_on                     = [azurerm_linux_web_app.linux_web_app]                                                                              # The diagnostic setting depends on the resource group
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-diagnostic-setting?ref=v1.0.0" # Source for the diagnostic setting module
  diag_name                      = lower("webapp-${azurerm_linux_web_app.linux_web_app[each.key].name}-diag")                                         # Name of the diagnostic setting
  resource_id                    = azurerm_linux_web_app.linux_web_app[each.key].id                                                                   # Resource ID to monitor
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id != null ? each.value.log_analytics_workspace_id : null                       # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                                                                                                        # Type of Log Analytics destination
  # Metrics to be collected
  logs_destinations_ids = [
    each.value.log_analytics_workspace_id != null ? each.value.log_analytics_workspace_id : null # Log Analytics workspace ID
  ]
}