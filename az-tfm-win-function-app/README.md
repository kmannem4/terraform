<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage windows function app in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
locals {
  is_kv_access_policy_required                 = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_kv_access_policy_required", false) == true }
  is_network_config_required                   = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_network_config_required", false) == true }
  is_virtual_network_swift_connection_required = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_virtual_network_swift_connection_required", false) == true }
  is_log_analytics_workspace_id_required       = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_log_analytics_workspace_id_required", false) == true }
}
#---------------------------------------------------------------
# Create Windows Function App
#---------------------------------------------------------------

resource "azurerm_windows_function_app" "function_app" {
  for_each                   = var.function_app_name_vars
  name                       = each.value.function_app_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  storage_account_name       = data.azurerm_storage_account.storage_account[each.key].name
  storage_account_access_key = data.azurerm_storage_account.storage_account[each.key].primary_access_key
  service_plan_id            = data.azurerm_service_plan.app-service-plan[each.key].id
  https_only                 = each.value.https_only
  app_settings               = each.value.app_settings
  site_config {
    use_32_bit_worker   = false
    ftps_state          = each.value.ftps_state
    minimum_tls_version = each.value.minimum_tls_version
    dynamic "ip_restriction" {
      for_each = each.value.ip_restrictions
      content {
        ip_address  = ip_restriction.value.ipAddress
        action      = ip_restriction.value.action
        service_tag = ip_restriction.value.service_tag
        priority    = ip_restriction.value.priority
        name        = ip_restriction.value.name
        description = ip_restriction.value.description
      }
    }
  }
  virtual_network_subnet_id = each.value.is_virtual_network_swift_connection_required ? null : each.value.is_network_config_required ? data.azurerm_subnet.subnet[each.key].id : null
  dynamic "identity" {
    for_each = each.value.function_app_identity != null ? [1] : []
    content {
      type = each.value.function_app_identity.function_app_identity_type
    }
  }
  tags = var.tags
}

#---------------------------------------------------------------
# Vnet Integration for Windows Function App
#---------------------------------------------------------------

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  for_each       = local.is_virtual_network_swift_connection_required
  depends_on     = [azurerm_windows_function_app.function_app]
  app_service_id = azurerm_windows_function_app.function_app[each.key].id
  subnet_id      = data.azurerm_subnet.subnet[each.key].id
}

#---------------------------------------------------------------
# Key Vault Secret Access Permission for Windows Function App
#---------------------------------------------------------------

resource "azurerm_key_vault_access_policy" "kv_access_policies" {
  for_each           = local.is_kv_access_policy_required
  depends_on         = [azurerm_windows_function_app.function_app]
  key_vault_id       = data.azurerm_key_vault.key_vault[each.key].id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_windows_function_app.function_app[each.key].identity[0].principal_id
  secret_permissions = each.value.secret_permissions
}

#-------------------------------------------------
# Module to create a diagnostic setting
module "diagnostic" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  for_each                       = local.is_log_analytics_workspace_id_required
  depends_on                     = [azurerm_windows_function_app.function_app]                                                                        # The diagnostic setting depends on the resource group
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-diagnostic-setting?ref=v1.0.0" # Source for the diagnostic setting module
  diag_name                      = lower("webapp-${azurerm_windows_function_app.function_app[each.key].name}-diag")                                   # Name of the diagnostic setting
  resource_id                    = azurerm_windows_function_app.function_app[each.key].id                                                             # Resource ID to monitor
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id != null ? each.value.log_analytics_workspace_id : null                       # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                                                                                                        # Type of Log Analytics destination
  # Metrics to be collected
  logs_destinations_ids = [
    each.value.log_analytics_workspace_id != null ? each.value.log_analytics_workspace_id : null # Log Analytics workspace ID
  ]
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_app_name_vars"></a> [function\_app\_name\_vars](#input\_function\_app\_name\_vars) | The name of the Function App. | <pre>map(object({<br>    function_app_name                            = string       #The name of the Function App.<br>    app_service_plan_name                        = string       #The name of the App Service Plan.<br>    storage_account_name                         = string       #The name of the Storage Account.<br>    virtual_network_name                         = string       #The name of the Virtual Network for Vnet Integration.<br>    vnet_subnet                                  = string       #The name of the Subnet for Vnet Integration.<br>    vnet_resource_group_name                     = string       #The name of the Resource Group for Vnet Integration.<br>    storage_resource_group_name                  = string       #The name of the Resource Group for Storage Account.<br>    key_vault_resource_group_name                = string       #The name of the Resource Group for Key Vault.<br>    key_vault                                    = string       #The name of the Key Vault for Key Vault Secret Access.<br>    https_only                                   = bool         #Configures a web site to accept only https requests. Default value is false.<br>    app_settings                                 = map(string)  #A key-value pair of App Settings.<br>    secret_permissions                           = list(string) #The permissions the Function App identity has on the Key Vault Secret.<br>    ftps_state                                   = string       #State of FTP / FTPS service for this function app. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.<br>    minimum_tls_version                          = string       #The minimum version of TLS required for this function app. Possible values include: 1.0, 1.1, 1.2. Default value is 1.2.<br>    public_network_access_enabled                = bool<br>    is_kv_access_policy_required                 = bool<br>    is_network_config_required                   = bool<br>    is_virtual_network_swift_connection_required = bool<br>    is_log_analytics_workspace_id_required       = bool<br>    log_analytics_workspace_id                   = string<br>    ip_restrictions = list(object({<br>      ipAddress   = string<br>      action      = string<br>      service_tag = string<br>      priority    = number<br>      name        = string<br>      description = string<br>    }))<br>    function_app_identity = object({<br>      function_app_identity_type = string<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Function App. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_app_key_vault_access_policy"></a> [function\_app\_key\_vault\_access\_policy](#output\_function\_app\_key\_vault\_access\_policy) | n/a |
| <a name="output_function_app_virtual_network_swift_connection"></a> [function\_app\_virtual\_network\_swift\_connection](#output\_function\_app\_virtual\_network\_swift\_connection) | n/a |
| <a name="output_windows_function_app"></a> [windows\_function\_app](#output\_windows\_function\_app) | n/a |

#### The following resources are created by this module:


- resource.azurerm_app_service_virtual_network_swift_connection.vnet_integration (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/main.tf#51)
- resource.azurerm_key_vault_access_policy.kv_access_policies (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/main.tf#62)
- resource.azurerm_windows_function_app.function_app (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/main.tf#11)
- data source.azurerm_client_config.current (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/data.tf#1)
- data source.azurerm_key_vault.key_vault (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/data.tf#22)
- data source.azurerm_service_plan.app-service-plan (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/data.tf#3)
- data source.azurerm_storage_account.storage_account (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/data.tf#9)
- data source.azurerm_subnet.subnet (/usr/agent/azp/_work/1/s/amn-az-tfm-win-function-app/data.tf#15)


## Example Scenario

Create windows function app <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create windows function app

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
  resource_group_suffix   = "rg"
  app_service_plan_suffix = "aspl"
  web_app_service_suffix  = "as"
  function_app_suffix     = "func"
  key_vault_suffix        = "kv"
  vnet_suffix             = "vnet"
  subnet_suffix           = "snet"
  storage_account_suffix  = "sa"
  environment_suffix      = "t01"
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

  resource_group_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  app_service_plan_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_service_plan_suffix}-${local.environment_suffix}"
  function_app_name     = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.function_app_suffix}-${local.environment_suffix}"
  key_vault_name        = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.key_vault_suffix}-${local.environment_suffix}"
  vnet_name             = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suffix}-${local.environment_suffix}"
  subnet_name           = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.subnet_suffix}-${local.environment_suffix}"
  storage_account_name  = "co${local.region_abbreviation}tfm${random_string.resource_name.result}${local.storage_account_suffix}${local.environment_suffix}"

  function_app_name_vars = {
    "function_app_1" = {
      function_app_name             = local.function_app_name
      app_service_plan_name         = local.app_service_plan_name
      storage_account_name          = local.storage_account_name
      storage_resource_group_name   = local.resource_group_name
      virtual_network_name          = local.vnet_name
      vnet_subnet                   = local.subnet_name
      vnet_resource_group_name      = local.resource_group_name
      key_vault_resource_group_name = local.resource_group_name
      key_vault                     = local.key_vault_name
      https_only                    = true
      public_network_access_enabled = true
      app_settings = {
        FUNCTIONS_EXTENSION_VERSION = "~4"
        FUNCTIONS_WORKER_RUNTIME    = "dotnet"
      }
      is_kv_access_policy_required                 = true
      virtual_network_subnet_id                    = false
      is_virtual_network_swift_connection_required = true
      is_network_config_required                   = true
      is_log_analytics_workspace_id_required       = false
      log_analytics_workspace_id                   = null
      secret_permissions                           = ["Get", "List"]
      ftps_state                                   = "Disabled"
      minimum_tls_version                          = "1.2"
      ip_restrictions = [
        {
          ipAddress   = null
          action      = "Allow"
          service_tag = "AzureCosmosDB"
          priority    = 300
          name        = "Allow_CosmosDB_Traffic_Only"
          description = "Allow_CosmosDB_Traffic_Only"
        },
        {
          ipAddress   = null
          action      = "Allow"
          service_tag = "ServiceBus"
          priority    = 300
          name        = "Allow_ServiceBus_Traffic_Only"
          description = "Allow_ServiceBus_Traffic_Only"
        },
        {
          ipAddress   = "0.0.0.0/0"
          action      = "Deny"
          priority    = 2147483647
          name        = "Deny all"
          description = "Deny all access"
          service_tag = null
        }
      ]
      function_app_identity = {
        function_app_identity_type = "SystemAssigned"
      }
    }
  }

  subnets = {
    mgnt_subnet1 = {
      subnet_name           = local.subnet_name
      subnet_address_prefix = ["10.85.0.192/26"]
      delegation = {
        name = "delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "app_service_plan" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                 = [module.rg]
  source                     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-app-service-plan?ref=v1.0.0"
  resource_group_name        = local.resource_group_name
  create_app_service_plan    = var.create_app_service_plan
  location                   = var.location
  os_type                    = var.os_type
  sku_name                   = var.sku_name
  app_service_plan_name      = local.app_service_plan_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

module "virtual_network" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [module.rg]
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-virtual-network?ref=v1.0.0"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  vnetwork_name                  = local.vnet_name
  vnet_address_space             = var.vnet_address_space
  subnets                        = local.subnets
  gateway_subnet_address_prefix  = var.gateway_subnet_address_prefix
  firewall_subnet_address_prefix = var.firewall_subnet_address_prefix
  create_network_watcher         = var.create_network_watcher
  create_ddos_plan               = var.create_ddos_plan
  edge_zone                      = var.edge_zone
  flow_timeout_in_minutes        = var.flow_timeout_in_minutes
  dns_servers                    = var.dns_servers
  tags                           = var.tags
  ddos_plan_name                 = var.ddos_plan_name
}


module "key_vault" {
  # version = "v1.0.0"
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkovLskip=CKV_AZURE_109: "Ensure that key vault allows firewall rules settings"
  depends_on                                 = [module.rg, module.virtual_network]
  source                                     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-key-vault?ref=v1.0.0"
  resource_group_name                        = local.resource_group_name
  key_vault_name                             = local.key_vault_name
  location                                   = var.location
  key_vault_sku_pricing_tier                 = var.key_vault_sku_pricing_tier
  enable_purge_protection                    = var.enable_purge_protection
  soft_delete_retention_days                 = var.soft_delete_retention_days
  self_key_permissions_access_policy         = var.self_key_permissions_access_policy
  self_secret_permissions_access_policy      = var.self_secret_permissions_access_policy
  self_certificate_permissions_access_policy = var.self_certificate_permissions_access_policy
  self_storage_permissions_access_policy     = var.self_storage_permissions_access_policy
  access_policies                            = var.access_policies
  secrets                                    = var.secrets
  enable_private_endpoint                    = var.enable_private_endpoint
  virtual_network_name                       = var.virtual_network_name
  private_subnet_address_prefix              = var.private_subnet_address_prefix
  public_network_access_enabled              = var.public_network_access_enabled
  enabled_for_template_deployment            = var.enabled_for_template_deployment
  enabled_for_disk_encryption                = var.enabled_for_disk_encryption
  enabled_for_deployment                     = var.enabled_for_deployment
  enable_rbac_authorization                  = var.enable_rbac_authorization
  tags                                       = var.tags
}

module "storage" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"

  depends_on                           = [module.rg]
  source                               = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-storage-account?ref=v1.0.0"
  resource_group_name                  = local.resource_group_name
  location                             = var.location
  storage_account_name                 = local.storage_account_name
  skuname                              = var.skuname
  account_kind                         = var.account_kind
  container_soft_delete_retention_days = var.container_soft_delete_retention_days
  blob_soft_delete_retention_days      = var.blob_soft_delete_retention_days
  public_network_access_enabled        = var.public_network_access_enabled
  containers_list                      = var.containers_list
  tags                                 = var.tags
}



module "function_app" {
  #checkov:skip=CKV_AZURE_221: Azure Function App public network access is enabled at present
  #checkov:skip=CKV_AZURE_70: Azure Function apps is only accessible over HTTPS
  #checkov:skip=CKV_AZURE_145: Azure Function apps is only accessible over HTTPS
  source                 = "../"
  depends_on             = [module.app_service_plan, module.key_vault, module.virtual_network, module.storage]
  location               = var.location
  function_app_name_vars = local.function_app_name_vars
  resource_group_name    = local.resource_group_name
  tags                   = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl

location                   = "westus2"
os_type                    = "Windows"
sku_name                   = "S2"
log_analytics_workspace_id = null
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

create_app_service_plan = true

key_vault_sku_pricing_tier      = "premium"
public_network_access_enabled   = true
enable_purge_protection         = false
enabled_for_template_deployment = true
enabled_for_disk_encryption     = true
enable_rbac_authorization       = false
enabled_for_deployment          = true
soft_delete_retention_days      = 90

self_key_permissions_access_policy         = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Update"]
self_secret_permissions_access_policy      = ["Get", "List", "Delete", "Recover", "Backup", "Restore", "Set", "Purge"]
self_certificate_permissions_access_policy = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"]
self_storage_permissions_access_policy     = ["Get", "List"]


# Access policies for users, you can provide list of Azure AD users and set permissions.
# Make sure to use list of user principal names of Azure AD users.
access_policies = []

# This will create secrets.
# When you Add `usernames` with empty password this module creates a strong random password
# use .tfvars file to manage the secrets as variables to avoid security issues.
secrets = {}

# This will create a `privatelink.vaultcore.azure.net` DNS zone by default.
# To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.
enable_private_endpoint       = false
virtual_network_name          = null
private_subnet_address_prefix = null

vnet_address_space      = ["10.85.0.0/24"]
create_ddos_plan        = false
ddos_plan_name          = ""
flow_timeout_in_minutes = 0

dns_servers                    = []
edge_zone                      = ""
firewall_subnet_address_prefix = ["10.85.0.0/25"]
gateway_subnet_address_prefix  = ["10.85.0.128/26"]

blob_soft_delete_retention_days      = 31
container_soft_delete_retention_days = 31
containers_list = [
  { name = "intelligence-hub", access_type = "private" },
  { name = "zipcodes", access_type = "private" }
]
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->