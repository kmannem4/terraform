<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage web app slot in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#---------------------------------
# Local declarations
#---------------------------------

locals {
  is_network_config_required                   = { for k, v in var.web_slot_vars : k => v if lookup(v, "is_network_config_required", false) == true }
  is_virtual_network_swift_connection_required = { for k, v in var.web_slot_vars : k => v if lookup(v, "is_virtual_network_swift_connection_required", false) == true }
  is_appinsights_instrumentation_key_required  = { for k, v in var.web_slot_vars : k => v if lookup(v, "is_appinsights_instrumentation_key_required", false) == true }
  is_kv_access_policy_required                 = { for k, v in var.web_slot_vars : k => v if lookup(v, "is_kv_access_policy_required", false) == true }
  is_log_analytics_workspace_id_required       = { for k, v in var.web_slot_vars : k => v if lookup(v, "is_log_analytics_workspace_id_required", false) == true }
}

#---------------------------------------------------------------
# Windows Web App Service slot
#---------------------------------------------------------------

resource "azurerm_windows_web_app_slot" "slot" {
  for_each       = var.web_slot_vars
  name           = each.value.web_app_slot_name
  app_service_id = data.azurerm_windows_web_app.win_web_app[each.key].id
  https_only     = each.value.web_app_https_only
  enabled        = each.value.is_web_app_enabled
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
          current_stack  = application_stack.value.current_stack
          dotnet_version = application_stack.value.current_stack == "dotnet" ? application_stack.value.dotnet_version : null
          java_version   = application_stack.value.current_stack == "java" ? application_stack.value.java_version : null
          node_version   = application_stack.value.current_stack == "node" ? application_stack.value.node_version : null
          php_version    = application_stack.value.current_stack == "php" ? application_stack.value.php_version : null
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
# Windows Web App Service Key Vault Access Policy
#-------------------------------------------------

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  for_each           = local.is_kv_access_policy_required
  key_vault_id       = data.azurerm_key_vault.key_vault[each.key].id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_windows_web_app_slot.slot[each.key].identity[0].principal_id
  secret_permissions = each.value.secret_permissions != null || each.value.secret_permissions != [] ? each.value.secret_permissions : []
  key_permissions    = each.value.key_permissions != null || each.value.key_permissions != [] ? each.value.key_permissions : []
}
#-------------------------------------------------
# Module to create a diagnostic setting
#-------------------------------------------------
module "diagnostic" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  for_each                       = local.is_log_analytics_workspace_id_required
  depends_on                     = [azurerm_windows_web_app_slot.slot]                                                                                # The diagnostic setting depends on the resource group
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-diagnostic-setting?ref=v1.0.0" # Source for the diagnostic setting module
  diag_name                      = lower("webapp-${azurerm_windows_web_app_slot.slot[each.key].name}-diag")                                           # Name of the diagnostic setting
  resource_id                    = azurerm_windows_web_app_slot.slot[each.key].id                                                                     # Resource ID to monitor
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
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace to send diagnostic logs to. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_web_slot_vars"></a> [web\_slot\_vars](#input\_web\_slot\_vars) | Map of variables for windows Web App slot | <pre>map(object({<br>    web_app_slot_name = string<br>    web_app_name      = string<br>    web_app_settings  = map(string)<br>    web_app_site_config = object({<br>      site_config_always_on           = bool<br>      site_config_ftps_state          = string<br>      site_config_minimum_tls_version = string<br>      site_config_http2_enabled       = bool<br>      site_config_use_32_bit_worker   = bool<br>      site_config_cors = list(object({<br>        site_config_cors_allowed_origins     = list(string)<br>        site_config_cors_support_credentials = string<br>      }))<br>      application_stack = optional(object({<br>        current_stack  = string<br>        dotnet_version = optional(string)<br>        java_version   = optional(string)<br>        node_version   = optional(string)<br>        php_version    = optional(string)<br>      }))<br>      web_app_ip_restriction = optional(map(object({<br>        web_app_ip_restriction_name                      = string<br>        web_app_ip_restriction_action                    = string<br>        web_app_ip_restriction_priority                  = string<br>        web_app_ip_restriction_ip_address                = optional(string)<br>        web_app_ip_restriction_service_tag               = optional(string)<br>        web_app_ip_restriction_virtual_network_subnet_id = optional(string)<br>        web_app_ip_restriction_headers = optional(list(object({<br>          headers_x_azure_fdid      = optional(list(string))<br>          headers_x_fd_health_probe = optional(list(string))<br>          headers_x_forwarded_for   = optional(list(string))<br>          headers_x_forwarded_host  = optional(list(string))<br>        })))<br>      })))<br>    })<br>    connection_strings = map(object({<br>      name  = string # Required: The name of the connection string<br>      type  = string # Required: The type of the database<br>      value = string # Required: The actual connection string value<br>    }))<br>    web_app_https_only                                 = bool<br>    is_web_app_enabled                                 = bool<br>    public_network_access_enabled                      = bool<br>    is_network_config_required                         = bool<br>    network_config_virtual_network_name                = string<br>    network_config_subnet_name                         = string<br>    network_config_virtual_network_resource_group_name = string<br>    is_virtual_network_swift_connection_required       = bool<br>    is_appinsights_instrumentation_key_required        = bool<br>    is_log_analytics_workspace_id_required             = bool<br>    log_analytics_workspace_id                         = string<br>    web_app_application_insights_name                  = string<br>    web_app_application_insights_resource_group_name   = string<br>    logs = list(object({<br>      application_logs = list(object({<br>        file_system_level = string<br>      }))<br>    }))<br>    key_permissions              = list(string)<br>    secret_permissions           = list(string)<br>    is_kv_access_policy_required = bool<br>    kv_name                      = string<br>    kv_resource_group_name       = string<br>    web_app_identity = object({<br>      web_app_identity_type = string<br>    })<br>  }))</pre> | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_windows_web_app_slot"></a> [azurerm\_windows\_web\_app\_slot](#output\_azurerm\_windows\_web\_app\_slot) | Windows Web App Slot Service |

#### The following resources are created by this module:


- resource.azurerm_key_vault_access_policy.key_vault_access_policy (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/main.tf#101)
- resource.azurerm_windows_web_app_slot.slot (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/main.tf#17)
- data source.azurerm_application_insights.application_insights (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/data.tf#7)
- data source.azurerm_client_config.current (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/data.tf#5)
- data source.azurerm_key_vault.key_vault (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/data.tf#20)
- data source.azurerm_subnet.subnet (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/data.tf#13)
- data source.azurerm_windows_web_app.win_web_app (/usr/agent/azp/_work/1/s/amn-az-tfm-win-web-app-slot/data.tf#26)


## Example Scenario

Create web app slot <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create app service plan<br /> - Create key vault<br /> - Create virtual network<br /> - Create web app<br /> - Create web app slot

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
  key_vault_suffix        = "kv"
  vnet_suffix             = "vnet"
  subnet_suffix           = "snet"
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

  # resource_group_name   = "co-wus2-amnoneshared-rg-t02"
  resource_group_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  app_service_plan_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_service_plan_suffix}-${local.environment_suffix}"
  web_app_service_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.web_app_service_suffix}-${local.environment_suffix}"
  key_vault_name        = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.key_vault_suffix}-${local.environment_suffix}"
  vnet_name             = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suffix}-${local.environment_suffix}"
  subnet_name           = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.subnet_suffix}-${local.environment_suffix}"

  web_app_service_vars = {
    "web_app_service_1" = {
      web_app_name          = local.web_app_service_name
      app_service_plan_name = local.app_service_plan_name
      web_app_settings = {
        "WEBJOBS_IDLE_TIMEOUT"                            = "100000"
        "WEBJOBS_LOG_TRIGGERED_JOBS_TO_APP_LOGS"          = "true"
        "SCM_COMMAND_IDLE_TIMEOUT"                        = 21600
        "NumberOfCongnitiveSearchUploadThreads"           = 2
        "AzureKeyVaultName"                               = local.key_vault_name
        "CognitiveSearchName"                             = "co-wus2-amnoneshared-acs-t02"
        "CognitiveSearchKey"                              = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=cognitive-search-apikey)"
        "AMIEDBSQLConstr"                                 = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=amiedb-sqlconnection-dataload)"
        "cosmosdb-uri-shared-shared"                      = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=cosmosdb-uri-shared-shared)"
        "cosmosdb-uri-candidatemgmt-candidateMgmt"        = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=cosmosdb-uri-candidatemgmt-candidateMgmt)"
        "CosmosDatabaseName"                              = "shared"
        "CosmosDatabaseNameCandidateMgmt"                 = "candidateMgmt"
        "CandidateSearchIndexName"                        = "acs-cosmos-candidatemgmt-candidatesearch-03"
        "FacilitySearchIndexName"                         = "acs-cosmos-ordermgmt-facilitysearch-03"
        "OrderSearchIndexName"                            = "acs-cosmos-ordermgmt-ordersearch-03"
        "PlacementSearchIndexName"                        = "acs-cosmos-ordermgmt-placementsearch-03"
        "ClientContactsIndexName"                         = "acs-cosmos-ordermgmt-clientcontacts-03"
        "CandidateSearchReadBatchBatchSize"               = 10000
        "CandidateSearchRunFullLoadBatchSize"             = 10000
        "CandidateSearchRunIncrementLoadBatchSize"        = 1000
        "IncrementalDenormalizationPullIntervalInSeconds" = 1
        "IncrementalPullIntervalInSeconds"                = 10
        "ReadBatchBatchSize"                              = 10000
        "RunFullLoadBatchSize"                            = 100000
        "RunIncrementLoadBatchSize"                       = 10000
        "SQLCommandTimeout"                               = 3600
        "SQLConnectionTimeout"                            = 60
        "SQLLongRunningCommandTimeout"                    = 7200
      }
      web_app_https_only = true
      web_app_site_config = {
        site_config_always_on           = true
        site_config_ftps_state          = "Disabled"
        site_config_minimum_tls_version = "1.2"
        site_config_http2_enabled       = true
        site_config_use_32_bit_worker   = false
        site_config_cors = [{
          site_config_cors_allowed_origins     = ["https://amnone.t02.amnhealthcare.io"]
          site_config_cors_support_credentials = true
        }]
        web_app_ip_restriction = null
        application_stack = {
          current_stack  = "dotnet"
          dotnet_version = "v6.0"
        }
      }
      connection_strings                                 = null
      is_web_app_enabled                                 = true
      is_network_config_required                         = false
      network_config_virtual_network_name                = local.vnet_name
      network_config_subnet_name                         = local.subnet_name
      network_config_virtual_network_resource_group_name = local.resource_group_name
      is_virtual_network_swift_connection_required       = false
      is_appinsights_instrumentation_key_required        = false
      is_log_analytics_workspace_id_required             = false
      log_analytics_workspace_id                         = null
      web_app_application_insights_name                  = "co-wus2-amnoneshared-ai-t02"
      web_app_application_insights_resource_group_name   = "co-wus2-amnoneshared-rg-t02"
      public_network_access_enabled                      = true
      logs = [{
        application_logs = [{
          file_system_level = "Information"
        }]
      }]
      secret_permissions           = ["Get", "List"]
      key_permissions              = ["Get", "List"]
      is_kv_access_policy_required = true
      kv_name                      = local.key_vault_name
      kv_resource_group_name       = local.resource_group_name
      web_app_identity = {
        web_app_identity_type = "SystemAssigned"
      }
    }
  }
  web_slot_vars = {
    "web_app_service_1" = {
      web_app_name          = local.web_app_service_name
      app_service_plan_name = local.app_service_plan_name
      web_app_settings = {
        "WEBJOBS_IDLE_TIMEOUT"                            = "100000"
        "WEBJOBS_LOG_TRIGGERED_JOBS_TO_APP_LOGS"          = "true"
        "SCM_COMMAND_IDLE_TIMEOUT"                        = 21600
        "NumberOfCongnitiveSearchUploadThreads"           = 2
        "AzureKeyVaultName"                               = local.key_vault_name
        "CognitiveSearchName"                             = "co-wus2-amnoneshared-acs-t02"
        "CognitiveSearchKey"                              = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=cognitive-search-apikey)"
        "AMIEDBSQLConstr"                                 = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=amiedb-sqlconnection-dataload)"
        "cosmosdb-uri-shared-shared"                      = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=cosmosdb-uri-shared-shared)"
        "cosmosdb-uri-candidatemgmt-candidateMgmt"        = "@Microsoft.KeyVault(VaultName=${local.key_vault_name};SecretName=cosmosdb-uri-candidatemgmt-candidateMgmt)"
        "CosmosDatabaseName"                              = "shared"
        "CosmosDatabaseNameCandidateMgmt"                 = "candidateMgmt"
        "CandidateSearchIndexName"                        = "acs-cosmos-candidatemgmt-candidatesearch-03"
        "FacilitySearchIndexName"                         = "acs-cosmos-ordermgmt-facilitysearch-03"
        "OrderSearchIndexName"                            = "acs-cosmos-ordermgmt-ordersearch-03"
        "PlacementSearchIndexName"                        = "acs-cosmos-ordermgmt-placementsearch-03"
        "ClientContactsIndexName"                         = "acs-cosmos-ordermgmt-clientcontacts-03"
        "CandidateSearchReadBatchBatchSize"               = 10000
        "CandidateSearchRunFullLoadBatchSize"             = 10000
        "CandidateSearchRunIncrementLoadBatchSize"        = 1000
        "IncrementalDenormalizationPullIntervalInSeconds" = 1
        "IncrementalPullIntervalInSeconds"                = 10
        "ReadBatchBatchSize"                              = 10000
        "RunFullLoadBatchSize"                            = 100000
        "RunIncrementLoadBatchSize"                       = 10000
        "SQLCommandTimeout"                               = 3600
        "SQLConnectionTimeout"                            = 60
        "SQLLongRunningCommandTimeout"                    = 7200
      }
      web_app_https_only = true
      web_app_slot_name  = "staging"
      web_app_site_config = {
        site_config_always_on           = true
        site_config_ftps_state          = "Disabled"
        site_config_minimum_tls_version = "1.2"
        site_config_http2_enabled       = true
        site_config_use_32_bit_worker   = false
        site_config_cors = [{
          site_config_cors_allowed_origins     = ["https://amnone.t02.amnhealthcare.io"]
          site_config_cors_support_credentials = true
        }]
        web_app_ip_restriction = null
        application_stack = {
          current_stack  = "dotnet"
          dotnet_version = "v6.0"
        }
      }
      connection_strings                                 = null
      is_web_app_enabled                                 = true
      is_network_config_required                         = false
      network_config_virtual_network_name                = local.vnet_name
      network_config_subnet_name                         = local.subnet_name
      network_config_virtual_network_resource_group_name = local.resource_group_name
      is_virtual_network_swift_connection_required       = false
      is_appinsights_instrumentation_key_required        = false
      is_log_analytics_workspace_id_required             = false
      log_analytics_workspace_id                         = null
      web_app_application_insights_name                  = "co-wus2-amnoneshared-ai-t02"
      web_app_application_insights_resource_group_name   = "co-wus2-amnoneshared-rg-t02"
      public_network_access_enabled                      = true
      logs = [{
        application_logs = [{
          file_system_level = "Information"
        }]
      }]
      secret_permissions           = ["Get", "List"]
      key_permissions              = ["Get", "List"]
      is_kv_access_policy_required = true
      kv_name                      = local.key_vault_name
      kv_resource_group_name       = local.resource_group_name
      web_app_identity = {
        web_app_identity_type = "SystemAssigned"
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
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "app_service_plan" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
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
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
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
  # version = "1.0.0"
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
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



module "web_app_service" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_AZURE_14: "Ensure web app redirects all HTTP traffic to HTTPS in Azure App Service"
  #checkov:skip=CKV_AZURE_78: "Ensure FTP deployments are disabled"
  #checkov:skip=CKV_AZURE_13: "Ensure App Service Authentication is set on Azure App Service"
  #checkov:skip=CKV_AZURE_17: "Ensure the web app has ‘Client Certificates (Incoming client certificates)’ set to 'On'"
  #checkov:skip=CKV_AZURE_65: "Ensure that App service enables detailed error messages"
  #checkov:skip=CKV_AZURE_214: "The web app is not using a custom domain name"
  #checkov:skip=CKV_AZURE_66: "Ensure that App service enables failed request tracing"
  #checkov:skip=CKV_AZURE_222: "Ensure that Azure Web App public network access is disabled"
  #checkov:skip=CKV_AZURE_63: "Ensure that App service enables HTTP logging"
  #checkov:skip=CKV_AZURE_15: "Ensure web app is using the latest version of TLS encryption"
  #checkov:skip=CKV_AZURE_18: "Ensure that ‘HTTP Version’ is the latest if used to run the web app"
  #checkov:skip=CKV_AZURE_88: "Ensure that app services use Azure Files"
  #checkov:skip=CKV_AZURE_213: "Ensure that App Service configures health check"
  #checkov:skip=CKV_AZURE_153: "Ensure web app redirects all HTTP traffic to HTTPS in Azure App Service Slot"	
  depends_on           = [module.app_service_plan, module.key_vault, module.virtual_network]
  source               = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-win-web-app?ref=v1.0.1"
  web_app_service_vars = local.web_app_service_vars
  location             = var.location
  resource_group_name  = local.resource_group_name
  tags                 = var.tags
}

module "web_app_slot" {
  #checkov:skip=CKV_AZURE_153: "Ensure web app redirects all HTTP traffic to HTTPS in Azure App Service Slot"
  depends_on                 = [module.app_service_plan, module.key_vault, module.virtual_network, module.web_app_service]
  source                     = "../"
  resource_group_name        = local.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  web_slot_vars              = local.web_slot_vars
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
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->