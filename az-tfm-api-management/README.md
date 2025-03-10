<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to create API Management resource in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_api_management" "apim" {
  name                = var.api_management["name"]
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.api_management["publisher_name"]
  publisher_email     = var.api_management["publisher_email"]
  sku_name            = "${var.api_management["sku_tier"]}_${var.api_management["sku_capacity"]}"
  tags                = var.tags
  dynamic "additional_location" {
    for_each = var.api_management["additional_location"] == null ? [] : [var.api_management["additional_location"]]
    content {
      location             = additional_location.value["location"]
      capacity             = additional_location.value["capacity"]
      zones                = additional_location.value["zones"]
      public_ip_address_id = additional_location.value["public_ip_address_id"]
      dynamic "virtual_network_configuration" {
        for_each = additional_location.value["virtual_network_configuration"] == null ? [] : [additional_location.value["virtual_network_configuration"]]
        content {
          subnet_id = additional_location.value.virtual_network_configuration["subnet_id"]
        }
      }
    }
  }
  dynamic "certificate" {
    for_each = var.api_management["certificate"] == null ? [] : [var.api_management["certificate"]]
    content {
      encoded_certificate  = certificate.value["encoded_certificate"]
      certificate_password = certificate.value["certificate_password"]
      store_name           = certificate.value["store_name"]
    }
  }
  client_certificate_enabled = var.api_management["client_certificate_enabled"]
  dynamic "delegation" {
    for_each = var.api_management["delegation"] == null ? [] : [var.api_management["delegation"]]
    content {
      subscriptions_enabled = delegation.value["subscriptions_enabled"]
      url                   = delegation.value["url"]
      validation_key        = delegation.value["validation_key"]
    }
  }
  gateway_disabled = var.api_management["gateway_disabled"]
  min_api_version  = var.api_management["min_api_version"]
  
  dynamic "identity" {
    for_each = var.api_management["identity"] == null ? [] : [var.api_management["identity"]]
    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }
  zones= var.api_management["zones"]
  dynamic "hostname_configuration" {
    for_each = var.api_management["hostname_configuration"] == null ? [] : [var.api_management["hostname_configuration"]]
    content {
      developer_portal {
        host_name                       = hostname_configuration.value["developer_portal"]["hostname"]
        key_vault_id                    = hostname_configuration.value["developer_portal"]["key_vault_id"]
        certificate                     = hostname_configuration.value["developer_portal"]["certificate"]
        certificate_password            = hostname_configuration.value["developer_portal"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["developer_portal"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["developer_portal"]["ssl_keyvault_identity_client_id"]
      }
      management {
        host_name                       = hostname_configuration.value["management"]["hostname"]
        key_vault_id                    = hostname_configuration.value["management"]["key_vault_id"]
        certificate                     = hostname_configuration.value["management"]["certificate"]
        certificate_password            = hostname_configuration.value["management"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["management"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["management"]["ssl_keyvault_identity_client_id"]
      }
      portal {
        host_name                       = hostname_configuration.value["portal"]["hostname"]
        key_vault_id                    = hostname_configuration.value["portal"]["key_vault_id"]
        certificate                     = hostname_configuration.value["portal"]["certificate"]
        certificate_password            = hostname_configuration.value["portal"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["portal"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["portal"]["ssl_keyvault_identity_client_id"]
      }
      scm {
        host_name                       = hostname_configuration.value["scm"]["hostname"]
        key_vault_id                    = hostname_configuration.value["scm"]["key_vault_id"]
        certificate                     = hostname_configuration.value["scm"]["certificate"]
        certificate_password            = hostname_configuration.value["scm"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["scm"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["scm"]["ssl_keyvault_identity_client_id"]
      }
      proxy {
        host_name                       = hostname_configuration.value["proxy"]["hostname"]
        key_vault_id                    = hostname_configuration.value["proxy"]["key_vault_id"]
        certificate                     = hostname_configuration.value["proxy"]["certificate"]
        certificate_password            = hostname_configuration.value["proxy"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["proxy"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["proxy"]["ssl_keyvault_identity_client_id"]
      }
    }
  }
  notification_sender_email = var.api_management["notification_sender_email"]
  dynamic "protocols" {
    for_each = var.api_management["protocols"] == null ? [] : [var.api_management["protocols"]]
    content {
      enable_http2 = protocols.value["enable_http2"]
  }
  }
  dynamic "security" {
    for_each = var.api_management["security"] == null ? [] : [var.api_management["security"]]
    content {
      enable_backend_ssl30 = security.value["enable_backend_ssl30"]
      enable_backend_tls10 = security.value["enable_backend_tls10"]
      enable_backend_tls11 = security.value["enable_backend_tls11"]
      enable_frontend_ssl30 = security.value["enable_frontend_ssl30"]
      enable_frontend_tls10 = security.value["enable_frontend_tls10"]
      enable_frontend_tls11 = security.value["enable_frontend_tls11"]
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled     = security.value["tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled"]
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled     = security.value["tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled"]
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled       = security.value["tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled"]
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled       = security.value["tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled"]
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled          = security.value["tls_rsa_with_aes128_cbc_sha256_ciphers_enabled"]
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled             = security.value["tls_rsa_with_aes128_cbc_sha_ciphers_enabled"]
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled          = security.value["tls_rsa_with_aes128_gcm_sha256_ciphers_enabled"]
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled          = security.value["tls_rsa_with_aes256_gcm_sha384_ciphers_enabled"]
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled          = security.value["tls_rsa_with_aes256_cbc_sha256_ciphers_enabled"]
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled             = security.value["tls_rsa_with_aes256_cbc_sha_ciphers_enabled"]
      triple_des_ciphers_enabled = security.value["triple_des_ciphers_enabled"]
  }
  }
  dynamic "sign_in" {
    for_each = var.api_management["sign_in"] == null ? [] : [var.api_management["sign_in"]]
    content {
    enabled = sign_in.value["enabled"]
    }
  }
  dynamic "sign_up" {
    for_each = var.api_management["sign_up"] == null ? [] : [var.api_management["sign_up"]]
    content {
      enabled = sign_up.value["enabled"]
      terms_of_service {
        enabled = sign_up.value["terms_of_service"]["enabled"]
        consent_required = sign_up.value["terms_of_service"]["consent_required"]
        text = sign_up.value["terms_of_service"]["text"]
      }
      }
  }
  dynamic "tenant_access" {
    for_each = var.api_management["tenant_access"] == null ? [] : [var.api_management["tenant_access"]]
    content {
      enabled = tenant_access.value["enabled"]
    }
  }
  public_ip_address_id = var.api_management["public_ip_address_id"]
  public_network_access_enabled = var.api_management["public_network_access_enabled"]
  virtual_network_type = var.api_management["virtual_network_type"]
  dynamic "virtual_network_configuration" {
   for_each = var.api_management["virtual_network_configuration"] == null ? [] : [var.api_management["virtual_network_configuration"]]
   content {
        subnet_id = virtual_network_configuration.value["subnet_id"]
      }
   }  
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_management"></a> [api\_management](#input\_api\_management) | The configuration of API Management. | <pre>object({<br>    name                     = string<br>    publisher_name           = string<br>    publisher_email          = string<br>    sku_tier                 = string<br>    sku_capacity             = number<br>    additional_location      = optional(list(object({<br>      location            = string<br>      capacity            = optional(number)<br>      zones               = optional(number)<br>      public_ip_adress_id = optional(string)<br>      virtual_network_configuration = optional(list(object({<br>        subnet_id = string<br>      })))<br>      gateway_disabled = optional(string)<br>    })))<br>    certificate = optional(list(object({<br>      encoded_certificate  = string<br>      store_name           = string<br>      certificate_password = optional(string)<br>    })))<br>    client_certificate_enabled = optional(string)<br>    delegation = optional(list(object({<br>      subscriptions_enabled = optional(bool, false)<br>      url                   = optional(string)<br>      validation_key        = optional(string)<br>    })))<br>    gateway_disabled = optional(bool, false)<br>    min_api_version   = optional(string)<br>    zones              = optional(list(string))<br>    identity = optional(list(object({<br>      type         = string<br>      identity_ids = optional(string)<br>    })))<br>    hostname_configuration = optional(list(object({<br>      management = optional(list(object({<br>        hostname                        = string<br>        key_vault_id                    = optional(string)<br>        certificate                     = optional(string)<br>        certificate_password            = optional(string)<br>        negotiate_client_certificate    = optional(bool, false)<br>        ssl_keyvault_identity_client_id = optional(string)<br>      })))<br>      portal = optional(list(object({<br>        hostname                        = string<br>        key_vault_id                    = optional(string)<br>        certificate                     = optional(string)<br>        certificate_password            = optional(string)<br>        negotiate_client_certificate    = optional(bool, false)<br>        ssl_keyvault_identity_client_id = optional(string)<br>      })))<br>      developer_portal = optional(list(object({<br>        hostname                        = string<br>        key_vault_id                    = optional(string)<br>        certificate                     = optional(string)<br>        certificate_password            = optional(string)<br>        negotiate_client_certificate    = optional(bool, false)<br>        ssl_keyvault_identity_client_id = optional(string)<br>      })))<br>      porxy = optional(list(object({<br>        default_ssl_binding             = optional(bool, false)<br>        hostname                        = string<br>        key_vault_id                    = optional(string)<br>        certificate                     = optional(string)<br>        certificate_password            = optional(string)<br>        negotiate_client_certificate    = optional(bool, false)<br>        ssl_keyvault_identity_client_id = optional(string)<br>      })))<br>      scm = optional(list(object({<br>        hostname                        = string<br>        key_vault_id                    = optional(string)<br>        certificate                     = optional(string)<br>        certificate_password            = optional(string)<br>        negotiate_client_certificate    = optional(bool, false)<br>        ssl_keyvault_identity_client_id = optional(string)<br>      })))<br>    })))<br>    notification_sender_email = optional(string)<br>    protocols = optional(list(object({<br>      enable_http2 = optional(bool, false)<br>    })))<br>    security = optional(list(object({<br>      enable_backend_ssl30                                    = optional(bool, false)<br>      enable_backend_tls10                                    = optional(bool, false)<br>      enable_backend_tls11                                    = optional(bool, false)<br>      enable_frontend_ssl30                                   = optional(bool, false)<br>      enable_frontend_tls10                                   = optional(bool, false)<br>      enable_frontend_tls11                                   = optional(bool, false)<br>      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled     = optional(bool, false)<br>      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled     = optional(bool, false)<br>      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled       = optional(bool, false)<br>      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled       = optional(bool, false)<br>      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled          = optional(bool, false)<br>      tls_rsa_with_aes128_cbc_sha_ciphers_enabled             = optional(bool, false)<br>      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled          = optional(bool, false)<br>      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled          = optional(bool, false)<br>      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled          = optional(bool, false)<br>      tls_rsa_with_aes256_cbc_sha_ciphers_enabled             = optional(bool, false)<br>      triple_des_ciphers_enabled                              = optional(string)<br>    })))<br>    sign_in = optional(list(object({<br>      enabled = string<br>    })))<br>    sign_up = optional(list(object({<br>      enabled = string<br>      terms_of_service = list(object({<br>        consent_required = string<br>        enabled          = string<br>        text             = optional(string)<br>      }))<br>    })))<br>    tenant_access = optional(list(object({<br>      enabled = string<br>    })))<br>    public_ip_address_id       = optional(string)<br>    public_network_access_enabled = optional(string)<br>    virtual_network_type      = optional(string)<br>    virtual_network_configuration = optional(list(object({<br>      subnet_id = string<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | value to create location | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | value to create resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that should be present on the AKS cluster resources | `map(string)` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_location"></a> [additional\_location](#output\_additional\_location) | A `additional_location` block as defined below |
| <a name="output_api_management_id"></a> [api\_management\_id](#output\_api\_management\_id) | The ID of the API Management resource |
| <a name="output_api_management_name"></a> [api\_management\_name](#output\_api\_management\_name) | The Name of the API Management resource |
| <a name="output_certificate"></a> [certificate](#output\_certificate) | A `certificate` block as defined below |
| <a name="output_developer_portal"></a> [developer\_portal](#output\_developer\_portal) | A `developer_portal` block as defined below |
| <a name="output_gateway_regional_url"></a> [gateway\_regional\_url](#output\_gateway\_regional\_url) | The URL for the API Management Service's Gateway. |
| <a name="output_gateway_url"></a> [gateway\_url](#output\_gateway\_url) | The URL for the API Management Service's Gateway. |
| <a name="output_hostname_configuration"></a> [hostname\_configuration](#output\_hostname\_configuration) | A `hostname_configuration` block as defined below |
| <a name="output_identity"></a> [identity](#output\_identity) | An `identity` block as defined below |
| <a name="output_management_api_url"></a> [management\_api\_url](#output\_management\_api\_url) | The URL for the API Management Service's Management API. |
| <a name="output_portal_url"></a> [portal\_url](#output\_portal\_url) | The URL for the API Management Service's Portal. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | A list of private IP addresses assigned to this API Management service. Each address is a string |
| <a name="output_proxy"></a> [proxy](#output\_proxy) | A `proxy` block as defined below |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | A list of public IP addresses assigned to this API Management service. Each address is a string |
| <a name="output_scm_url"></a> [scm\_url](#output\_scm\_url) | The URL for the API Management Service's SCM (Git-based version control) |
| <a name="output_tenant_access"></a> [tenant\_access](#output\_tenant\_access) | A `tenant_access` block as defined below |

#### The following resources are created by this module:


- resource.azurerm_api_management.apim (/usr/agent/azp/_work/1/s/amn-az-tfm-api-management/main.tf#1)


## Example Scenario

Create API Management Resource in Azure. <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create API Management Resource

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
  resource_group_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  api_management = {
    name                     = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.environment_suffix}"
    publisher_name           = "test"
    publisher_email          = "test@test.com"
    sku_tier                 = "Premium"
    sku_capacity             = "1"
    additionallocation = [
      {
        location = "westcentralus"
      }
    ]
  }
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
module "apim" {
  #checkov:skip=CKV_AZURE_173: "Ensure API management uses at least TLS 1.2"
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
  api_management      = local.api_management
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location                = "westus2"
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
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->