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
