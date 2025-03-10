#-------------------------------
# Local Declarations
#-------------------------------
locals {
  paired_regions = {
    eastasia           = "southeastasia"
    southeastasia      = "eastasia"
    centralus          = "eastus2"
    eastus             = "westus"
    eastus2            = "centralus"
    westus             = "eastus"
    northcentralus     = "southcentralus"
    southcentralus     = "northcentralus"
    northeurope        = "westeurope"
    westeurope         = "northeurope"
    japanwest          = "japaneast"
    japaneast          = "japanwest"
    brazilsouth        = "southcentralus"
    australiaeast      = "australiasoutheast"
    australiasoutheast = "australiaeast"
    southindia         = "centralindia"
    centralindia       = "southindia"
    westindia          = "southindia"
    canadacentral      = "canadaeast"
    canadaeast         = "canadacentral"
    uksouth            = "ukwest"
    ukwest             = "uksouth"
    westcentralus      = "westus2"
    westus2            = "westcentralus"
    koreacentral       = "koreasouth"
    koreasouth         = "koreacentral"
    chinanorth         = "chinaeast"
    chinaeast          = "chinanorth"
    chinanorth2        = "chinaeast2"
    chinaeast2         = "chinanorth2"
  }
  paired_location = local.paired_regions[var.location]
  database_variables_list = [
    for db_name, db_config in var.cosmosdb_sql_database_variables != null ? var.cosmosdb_sql_database_variables : {} : {
      name               = db_config.cosmosdb_sql_database_name
      throughput         = db_config.cosmosdb_sql_database_throughput
      autoscale_settings = db_config.cosmosdb_sql_database_autoscale_settings
      containers = [
        for container_name, container_config in db_config.cosmosdb_sql_database_containers != null ? db_config.cosmosdb_sql_database_containers : {} : {
          container_name                       = container_config.cosmosdb_sql_container_name
          container_throughput                 = container_config.cosmosdb_sql_container_throughput
          container_partition_key_path         = container_config.cosmosdb_sql_container_partition_key_path
          container_partition_key_version      = container_config.cosmosdb_sql_container_partition_key_version
          container_unique_key                 = container_config.cosmosdb_sql_container_unique_key
          container_autoscale_settings         = container_config.cosmosdb_sql_container_autoscale_settings
          container_indexing_policy            = container_config.cosmosdb_sql_container_indexing_policy
          container_default_ttl                = container_config.cosmosdb_sql_container_default_ttl
          container_analytical_storage_ttl     = container_config.cosmosdb_sql_container_analytical_storage_ttl
          container_conflict_resolution_policy = container_config.cosmosdb_sql_container_conflict_resolution_policy
        }
      ]
    }
  ]
  container_variables_list = flatten([
    for k in local.database_variables_list : [
      for i in k.containers : merge({ "db_name" = k.name }, i)
    ]
  ])
  subnet_id_list = var.virtual_network_subnets != null ? {
    for idx, subnet_config in var.virtual_network_subnets :
    subnet_config.subnet_name => {
      id                                   = data.azurerm_subnet.subnet[idx].id
      ignore_missing_vnet_service_endpoint = subnet_config.ignore_missing_vnet_service_endpoint
    }
  } : {}
}

data "azurerm_key_vault" "key_vault" {
  count               = var.is_key_vault_cmk_encryption_in_use == true ? 1 : 0
  name                = var.cosmosdb_account_key_vault_name
  resource_group_name = var.cosmosdb_account_key_vault_resource_group_name
}

data "azurerm_key_vault_key" "key_vault_key" {
  count        = var.is_key_vault_cmk_encryption_in_use == true ? 1 : 0
  name         = var.cosmosdb_account_key_vault_key_name
  key_vault_id = data.azurerm_key_vault.key_vault[count.index].id
}

data "azurerm_subnet" "subnet" {
  count                = var.is_virtual_network_subnets_allowed == true ? length(var.virtual_network_subnets) : 0
  name                 = var.virtual_network_subnets[count.index].subnet_name
  virtual_network_name = var.virtual_network_subnets[count.index].virtual_network_name
  resource_group_name  = var.virtual_network_subnets[count.index].resource_group_name
}

# #---------------------------------------------------------
# # Cosmos DB Account Creation
# #----------------------------------------------------------

resource "azurerm_cosmosdb_account" "cosmons_db_account" {
  #checkov:skip=CKV_AZURE_132: skip
  #checkov:skip=CKV_AZURE_99: skip
  #checkov:skip=CKV_AZURE_100: skip
  #checkov:skip=CKV_AZURE_101: skip
  name                = var.cosmos_db_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge({ "ResourceName" = var.cosmos_db_account_name }, var.tags, )
  offer_type          = var.offer_type

  dynamic "analytical_storage" {
    for_each = var.analytical_storage_schema_type != null ? [1] : []
    content {
      schema_type = var.analytical_storage_schema_type
    }
  }

  dynamic "capacity" {
    for_each = var.total_throughput_limit_capacity != null ? [1] : []
    content {
      total_throughput_limit = var.total_throughput_limit_capacity
    }
  }

  create_mode           = var.create_mode
  default_identity_type = var.default_identity_type
  kind                  = var.kind
  consistency_policy {
    consistency_level       = var.cosmosdb_account_consistency_policy_consistency_level
    max_interval_in_seconds = var.cosmosdb_account_consistency_policy_max_interval_in_seconds
    max_staleness_prefix    = var.cosmosdb_account_consistency_policy_max_staleness_prefix
  }
  dynamic "geo_location" {
    for_each = var.is_zone_redundant == true ? [local.paired_location, var.location] : [var.location]

    content {
      location          = geo_location.value
      failover_priority = geo_location.value == local.paired_location ? 1 : 0
    }
  }
  ip_range_filter               = var.ip_range_filter
  free_tier_enabled             = var.enable_free_tier
  analytical_storage_enabled    = var.analytical_storage_enabled
  automatic_failover_enabled    = var.enable_automatic_failover
  public_network_access_enabled = var.public_network_access_enabled
  dynamic "capabilities" {
    for_each = var.cosmosdb_account_capabilities != null ? var.cosmosdb_account_capabilities : []
    content {
      name = capabilities.value.capabilities_name
    }
  }
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled
  key_vault_key_id                  = var.is_key_vault_cmk_encryption_in_use == true ? data.azurerm_key_vault_key.key_vault_key[0].versionless_id : null
  local_authentication_disabled     = var.local_authentication_disabled != null ? var.local_authentication_disabled : null

  dynamic "virtual_network_rule" {
    for_each = var.is_virtual_network_subnets_allowed != null ? local.subnet_id_list : {}
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }
  multiple_write_locations_enabled      = var.enable_multiple_write_locations
  access_key_metadata_writes_enabled    = var.access_key_metadata_writes_enabled
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids != null ? var.network_acl_bypass_ids : null

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  dynamic "restore" {
    for_each = var.enable_restore == true ? [1] : []
    content {
      source_cosmosdb_account_id = var.restore.restore_source_cosmosdb_account_id
      restore_timestamp_in_utc   = var.restore.restore_restore_timestamp_in_utc
      dynamic "database" {
        for_each = var.restore.restore_database == null ? [] : [var.restore.restore_database]
        content {
          name             = database.restore_database_name
          collection_names = database.restore_database_collection_names
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.cosmosdb_account_backup != null ? [var.cosmosdb_account_backup] : []
    content {
      type                = backup.value.backup_type
      interval_in_minutes = backup.value.backup_type == "Continuous" ? null : backup.value.backup_interval_in_minutes
      retention_in_hours  = backup.value.backup_type == "Continuous" ? null : backup.value.backup_retention_in_hours
      storage_redundancy  = backup.value.backup_type == "Continuous" ? null : backup.value.backup_storage_redundancy
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors_rule == null ? [] : [var.cors_rule]
    content {
      allowed_headers    = cors_rule.value.cors_rule_allowed_headers
      allowed_methods    = cors_rule.value.cors_rule_allowed_methods
      allowed_origins    = cors_rule.value.cors_rule_allowed_origins
      exposed_headers    = cors_rule.value.cors_rule_exposed_headers
      max_age_in_seconds = cors_rule.value.cors_rule_max_age_in_seconds
    }
  }

  lifecycle { prevent_destroy = false }
}


#---------------------------------------------------------
# Cosmos DB Account Database Creation 
#----------------------------------------------------------

resource "azurerm_cosmosdb_sql_database" "cosmosdb_sql_database" {

  depends_on = [azurerm_cosmosdb_account.cosmons_db_account]
  for_each = { for entry in local.database_variables_list :
    entry.name => entry
  }
  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_db_account_name
  throughput          = each.value.throughput
  dynamic "autoscale_settings" {
    for_each = (each.value.throughput == null && each.value.autoscale_settings != null) ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.autoscale_settings_max_throughput
    }
  }
}

#---------------------------------------------------------
# Cosmos DB Account Database Container Creation 
#----------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "cosmosdb_sql_container" {
  depends_on = [azurerm_cosmosdb_account.cosmons_db_account, azurerm_cosmosdb_sql_database.cosmosdb_sql_database]
  for_each = {
    for k in local.container_variables_list :
    "${k.db_name},${k.container_name}" => k
  }

  name                   = each.value.container_name
  resource_group_name    = var.resource_group_name
  account_name           = var.cosmos_db_account_name
  database_name          = each.value.db_name
  throughput             = each.value.container_throughput
  partition_key_paths    = each.value.container_partition_key_path
  partition_key_version  = each.value.container_partition_key_version
  default_ttl            = each.value.container_default_ttl
  analytical_storage_ttl = each.value.container_analytical_storage_ttl

  dynamic "unique_key" {
    for_each = each.value.container_unique_key != null ? each.value.container_unique_key : []
    content {
      paths = unique_key.value.unique_key_paths
    }
  }

  dynamic "autoscale_settings" {
    for_each = each.value.container_autoscale_settings != null && each.value.container_partition_key_path != null ? [1] : []
    content {
      max_throughput = each.value.container_autoscale_settings.autoscale_settings_max_throughput
    }
  }

  dynamic "indexing_policy" {
    for_each = each.value.container_indexing_policy != null ? [each.value.container_indexing_policy] : []
    content {
      indexing_mode = each.value.container_indexing_policy.indexing_policy_indexing_mode
      dynamic "included_path" {
        for_each = indexing_policy.value.indexing_policy_included_path != null ? indexing_policy.value.indexing_policy_included_path : []
        content {
          path = included_path.value.path
        }
      }

      dynamic "excluded_path" {
        for_each = each.value.container_indexing_policy.indexing_policy_excluded_path != null ? each.value.container_indexing_policy.indexing_policy_excluded_path : []
        content {
          path = excluded_path.value.path
        }
      }

      dynamic "composite_index" {
        for_each = each.value.container_indexing_policy.indexing_policy_composite_index != null ? each.value.container_indexing_policy.indexing_policy_composite_index : []
        content {
          dynamic "index" {
            for_each = composite_index.value.indexing_policy_composite_index.index != null ? composite_index.value.indexing_policy_composite_index.index : []
            content {
              path  = index.value.index_path
              order = index.value.index_order
            }
          }
        }
      }

      dynamic "spatial_index" {
        for_each = each.value.container_indexing_policy.indexing_policy_spatial_index != null ? each.value.container_indexing_policy.indexing_policy_spatial_index : []
        content {
          path = spatial_index.value.spatial_index_path
        }
      }
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = each.value.container_conflict_resolution_policy != null ? [each.value.container_conflict_resolution_policy] : []
    content {
      mode                          = conflict_resolution_policy.value.conflict_resolution_policy_mode
      conflict_resolution_path      = conflict_resolution_policy.value.conflict_resolution_policy_conflict_resolution_path
      conflict_resolution_procedure = conflict_resolution_policy.value.conflict_resolution_policy_conflict_resolution_procedure
    }
  }
}
