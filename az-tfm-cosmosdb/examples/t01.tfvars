access_key_metadata_writes_enabled = false
cosmos_db_account_name             = "co-wus2-tftest-cosmo-t01"
enable_automatic_failover          = false

enable_multiple_write_locations = false
is_zone_redundant               = false

create_mode = "Default"
kind        = "GlobalDocumentDB"

location                        = "westus2"
offer_type                      = "Standard"
public_network_access_enabled   = false
total_throughput_limit_capacity = null
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
cosmosdb_account_consistency_policy_max_interval_in_seconds = 5
cosmosdb_account_consistency_policy_max_staleness_prefix    = 100
managed_identity_type                                       = null
managed_identity_ids                                        = null
enable_free_tier                                            = false


cosmosdb_account_capabilities = [
  {
    capabilities_name = "AllowSelfServeUpgradeToMongo36"
  },
  {
    capabilities_name = "DisableRateLimitingResponses"
  }
]

cosmosdb_account_backup = {
  backup_type                = "Continuous"
  backup_interval_in_minutes = null
  backup_retention_in_hours  = null
  backup_storage_redundancy  = null
}

cosmosdb_sql_database_variables = {
  "cosmosdb_sql_database_1" = {
    cosmosdb_sql_database_name               = "credentialCandMgmt"
    cosmosdb_sql_database_throughput         = null
    cosmosdb_sql_database_autoscale_settings = null
    cosmosdb_sql_database_containers = {
      "cosmosdb_sql_container_1" = {

        # Specifies the name of the Cosmos DB SQL Container. 
        cosmosdb_sql_container_name = "exceptionWaiveAttachments"

        # Define a partition key. Changing this forces a new resource to be created.
        cosmosdb_sql_container_partition_key_path = ["/exceptionWaiveId"]

        # Define a partition key version. Changing this forces a new resource to be created.
        cosmosdb_sql_container_partition_key_version = 1

        # A list of paths to use for this unique key.
        cosmosdb_sql_container_unique_key = null

        # The throughput of SQL container (RU/s). Must be set in increments of 100. 
        cosmosdb_sql_container_throughput = null

        # An autoscale_settings block as defined below. This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.
        cosmosdb_sql_container_autoscale_settings = null

        cosmosdb_sql_container_indexing_policy = {
          # Indicates the indexing mode. 
          indexing_policy_indexing_mode = "consistent"
          # Either included_path or excluded_path must contain the path /*
          indexing_policy_included_path = [
            {
              path = "/*"
            }
          ]
          # Either included_path or excluded_path must contain the path /*
          indexing_policy_excluded_path = [
            {
              path = "/\"_etag\"/?"
            }
          ]

          indexing_policy_composite_index = null
          indexing_policy_spatial_index   = null
        }
        # The default time to live of SQL container. If missing, items are not expired automatically.
        cosmosdb_sql_container_default_ttl = null

        # The default time to live of Analytical Storage for this SQL container.
        cosmosdb_sql_container_analytical_storage_ttl = null

        # Defines conflict_resolution_policy
        cosmosdb_sql_container_conflict_resolution_policy = {
          # Indicates the conflict resolution mode.
          conflict_resolution_policy_mode = "LastWriterWins"
          # The conflict resolution path in the case of LastWriterWins mode.
          conflict_resolution_policy_conflict_resolution_path = "/_ts"
          # The procedure to resolve conflicts in the case of Custom mode.
          conflict_resolution_policy_conflict_resolution_procedure = null
        }
      },
      "cosmosdb_sql_container_2" = {

        # Specifies the name of the Cosmos DB SQL Container. 
        cosmosdb_sql_container_name = "credentialingOne"

        # Define a partition key. Changing this forces a new resource to be created.
        cosmosdb_sql_container_partition_key_path = ["/travelerId"]

        # Define a partition key version. Changing this forces a new resource to be created.
        cosmosdb_sql_container_partition_key_version = 1

        # A list of paths to use for this unique key.
        cosmosdb_sql_container_unique_key = null

        # The throughput of SQL container (RU/s). Must be set in increments of 100. 
        cosmosdb_sql_container_throughput = null

        # An autoscale_settings block as defined below. This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.
        cosmosdb_sql_container_autoscale_settings = null

        cosmosdb_sql_container_indexing_policy = {
          # Indicates the indexing mode. 
          indexing_policy_indexing_mode = "consistent"
          # Either included_path or excluded_path must contain the path /*
          indexing_policy_included_path = [
            {
              path = "/*"
            }
          ]
          # Either included_path or excluded_path must contain the path /*
          indexing_policy_excluded_path = [
            {
              path = "/\"_etag\"/?"
            }
          ]

          indexing_policy_composite_index = null
          indexing_policy_spatial_index   = null
        }
        # The default time to live of SQL container. If missing, items are not expired automatically.
        cosmosdb_sql_container_default_ttl = null

        # The default time to live of Analytical Storage for this SQL container.
        cosmosdb_sql_container_analytical_storage_ttl = null

        # Defines conflict_resolution_policy
        cosmosdb_sql_container_conflict_resolution_policy = {
          # Indicates the conflict resolution mode.
          conflict_resolution_policy_mode = "LastWriterWins"
          # The conflict resolution path in the case of LastWriterWins mode.
          conflict_resolution_policy_conflict_resolution_path = "/_ts"
          # The procedure to resolve conflicts in the case of Custom mode.
          conflict_resolution_policy_conflict_resolution_procedure = null
        }
      }
    }
  }
}


# Example - Multiple CosmosDB SQL Databases with multiple containers
# cosmosdb_sql_database_variables = {
#   "cosmosdb_sql_database_1" = {
#     cosmosdb_sql_database_name               = "credentialCandMgmt"
#     cosmosdb_sql_database_throughput         = 400
#     cosmosdb_sql_database_autoscale_settings = null
#     # cosmosdb_sql_database_containers         = null
#     cosmosdb_sql_database_containers = {
#       "cosmosdb_sql_container_1" = {
#         cosmosdb_sql_container_name                  = "exceptionWaiveAttachments"
#         cosmosdb_sql_container_partition_key_path    = "/definition/id"
#         cosmosdb_sql_container_partition_key_version = 1
#         cosmosdb_sql_container_unique_key = [
#           {
#             unique_key_paths = ["/definition/idlong", "/definition/idshort"]
#           }
#         ]

#         cosmosdb_sql_container_throughput = null
#         cosmosdb_sql_container_autoscale_settings = {
#           autoscale_settings_max_throughput = 1000
#         }
#         cosmosdb_sql_container_indexing_policy = {
#           indexing_policy_indexing_mode   = "consistent"
#           indexing_policy_included_path   = null
#           indexing_policy_excluded_path   = null
#           indexing_policy_composite_index = null
#           indexing_policy_spatial_index   = null
#         }
#         cosmosdb_sql_container_default_ttl            = null
#         cosmosdb_sql_container_analytical_storage_ttl = null
#         cosmosdb_sql_container_conflict_resolution_policy = {
#           conflict_resolution_policy_mode                          = "Custom"
#           conflict_resolution_policy_conflict_resolution_path      = null
#           conflict_resolution_policy_conflict_resolution_procedure = null
#         }
#       },
#       "cosmosdb_sql_container_2" = {
#         cosmosdb_sql_container_name                  = "exceptionWaiveAttachmen"
#         cosmosdb_sql_container_partition_key_path    = "/definition/id"
#         cosmosdb_sql_container_partition_key_version = 1
#         cosmosdb_sql_container_unique_key = [
#           {
#             unique_key_paths = ["/definition/idlong", "/definition/idshort"]
#           }
#         ]

#         cosmosdb_sql_container_throughput = null
#         cosmosdb_sql_container_autoscale_settings = {
#           autoscale_settings_max_throughput = 1000
#         }
#         cosmosdb_sql_container_indexing_policy = {
#           indexing_policy_indexing_mode   = "consistent"
#           indexing_policy_included_path   = null
#           indexing_policy_excluded_path   = null
#           indexing_policy_composite_index = null
#           indexing_policy_spatial_index   = null
#         }
#         cosmosdb_sql_container_default_ttl            = null
#         cosmosdb_sql_container_analytical_storage_ttl = null
#         cosmosdb_sql_container_conflict_resolution_policy = {
#           conflict_resolution_policy_mode                          = "Custom"
#           conflict_resolution_policy_conflict_resolution_path      = null
#           conflict_resolution_policy_conflict_resolution_procedure = null
#         }
#       }
#     }
#   },
#   "cosmosdb_sql_database_2" = {
#     cosmosdb_sql_database_name               = "credentialCandMgmt2"
#     cosmosdb_sql_database_throughput         = 400
#     cosmosdb_sql_database_autoscale_settings = null
#     cosmosdb_sql_database_containers         = null
#   }
# }
