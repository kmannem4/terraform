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
      # {
      #   "web_app_ip_restriction_1" = {
      #     web_app_ip_restriction_priority                  = 100
      #     web_app_ip_restriction_action                    = "Allow"
      #     web_app_ip_restriction_name                      = "Allow APIMv2 subnet"
      #     web_app_ip_restriction_virtual_network_subnet_id = "/subscriptions/e764d23e-759d-4cd4-8b5f-27e4c703f6a8/resourceGroups/amn-wus2-hub-rg-d01/providers/Microsoft.Network/virtualNetworks/amn-wus2-hub-vnet-d01/subnets/amn-hub-migrate-apim-sn"
      #   }
      # }
      connection_strings                                 = null
      is_web_app_enabled                                 = true
      is_network_config_required                         = true
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
