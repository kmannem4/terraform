<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage cosmosdb in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
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
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key_metadata_writes_enabled"></a> [access\_key\_metadata\_writes\_enabled](#input\_access\_key\_metadata\_writes\_enabled) | (Optional) Is write operations on metadata resources (databases, containers, throughput) via account keys enabled? | `bool` | `false` | no |
| <a name="input_analytical_storage_enabled"></a> [analytical\_storage\_enabled](#input\_analytical\_storage\_enabled) | (Optional) Enable Analytical Storage option for this Cosmos DB account. Defaults to false. Enabling and then disabling analytical storage forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_analytical_storage_schema_type"></a> [analytical\_storage\_schema\_type](#input\_analytical\_storage\_schema\_type) | (Required) The schema type of the Analytical Storage for this Cosmos DB account. Possible values are FullFidelity and WellDefined. | `string` | `null` | no |
| <a name="input_cors_rule"></a> [cors\_rule](#input\_cors\_rule) | #(Optional) Cross-Origin Resource Sharing (CORS) is an HTTP feature that enables a web application running under one domain to access resources in another domain. A cors\_rule block as defined below. | <pre>object({                               #(Optional) A cors_rule block as defined below.<br>    cors_rule_allowed_headers    = list(string) #(Required) A list of headers that are allowed to be a part of the cross-origin request.<br>    cors_rule_allowed_methods    = list(string) #(Required) A list of HTTP headers that are allowed to be executed by the origin. Valid options are DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT or PATCH.<br>    cors_rule_allowed_origins    = list(string) #(Required) A list of origin domains that will be allowed by CORS.<br>    cors_rule_exposed_headers    = list(string) #(Required) A list of response headers that are exposed to CORS clients.<br>    cors_rule_max_age_in_seconds = number       #(Required) The number of seconds the client should cache a preflight response.<br>  })</pre> | `null` | no |
| <a name="input_cosmos_db_account_name"></a> [cosmos\_db\_account\_name](#input\_cosmos\_db\_account\_name) | (Required) Specifies the name of this CosmosDB Account. | `string` | `""` | no |
| <a name="input_cosmosdb_account_backup"></a> [cosmosdb\_account\_backup](#input\_cosmosdb\_account\_backup) | (Optional) The backup which hould be enabled for this Cosmos DB account. | <pre>object({<br>    backup_type                = string #  (Required) The type of the backup. Possible values are Continuous and Periodic. Migration of Periodic to Continuous is one-way, changing Continuous to Periodic forces a new resource to be created. <br>    backup_interval_in_minutes = number #  (Optional) The interval in minutes between two backups. This is configurable only when type is Periodic. Possible values are between 60 and 1440.<br>    backup_retention_in_hours  = number #  (Optional) The time in hours that each backup is retained. This is configurable only when type is Periodic. Possible values are between 8 and 720.<br>    backup_storage_redundancy  = string #  (Optional) The storage redundancy is used to indicate the type of backup residency. This is configurable only when type is Periodic. Possible values are Geo, Local and Zone.<br>  })</pre> | `null` | no |
| <a name="input_cosmosdb_account_capabilities"></a> [cosmosdb\_account\_capabilities](#input\_cosmosdb\_account\_capabilities) | (Optional) The capabilities which should be enabled for this Cosmos DB account. | <pre>list(object({<br>    capabilities_name = string<br>  }))</pre> | `null` | no |
| <a name="input_cosmosdb_account_consistency_policy_consistency_level"></a> [cosmosdb\_account\_consistency\_policy\_consistency\_level](#input\_cosmosdb\_account\_consistency\_policy\_consistency\_level) | (Required) Configures the database consistency policy level. | `string` | `"Session"` | no |
| <a name="input_cosmosdb_account_consistency_policy_max_interval_in_seconds"></a> [cosmosdb\_account\_consistency\_policy\_max\_interval\_in\_seconds](#input\_cosmosdb\_account\_consistency\_policy\_max\_interval\_in\_seconds) | (Optional) Configures the database consistency policy max\_interval\_in\_seconds. | `number` | `5` | no |
| <a name="input_cosmosdb_account_consistency_policy_max_staleness_prefix"></a> [cosmosdb\_account\_consistency\_policy\_max\_staleness\_prefix](#input\_cosmosdb\_account\_consistency\_policy\_max\_staleness\_prefix) | (Optional) Configures the database consistency policy max\_staleness\_prefix. | `number` | `100` | no |
| <a name="input_cosmosdb_account_key_vault_key_name"></a> [cosmosdb\_account\_key\_vault\_key\_name](#input\_cosmosdb\_account\_key\_vault\_key\_name) | (Optional) A versionless Key Vault Key Name for CMK encryption. If is\_key\_vault\_cmk\_encryption\_in\_use is true then this is required. | `string` | `null` | no |
| <a name="input_cosmosdb_account_key_vault_name"></a> [cosmosdb\_account\_key\_vault\_name](#input\_cosmosdb\_account\_key\_vault\_name) | (Optional) A versionless Key Vault Name for CMK encryption. If is\_key\_vault\_cmk\_encryption\_in\_use is true then this is required. | `string` | `null` | no |
| <a name="input_cosmosdb_account_key_vault_resource_group_name"></a> [cosmosdb\_account\_key\_vault\_resource\_group\_name](#input\_cosmosdb\_account\_key\_vault\_resource\_group\_name) | (Optional) A versionless Key Vault Resource Group Name for CMK encryption. If is\_key\_vault\_cmk\_encryption\_in\_use is true then this is required. | `string` | `null` | no |
| <a name="input_cosmosdb_sql_database_variables"></a> [cosmosdb\_sql\_database\_variables](#input\_cosmosdb\_sql\_database\_variables) | CosmosDB SQL Database | <pre>map(object({<br>    cosmosdb_sql_database_name       = string                # (Required) Specifies the name of the Cosmos DB SQL Database. Changing this forces a new resource to be created.<br>    cosmosdb_sql_database_throughput = number                # (Optional) The throughput of SQL database (RU/s). Must be set in increments of 100. The minimum value is 400. This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.<br>    cosmosdb_sql_database_autoscale_settings = list(object({ # (Optional) This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.<br>      autoscale_settings_max_throughput = number             # (Optional) The maximum throughput of the SQL database (RU/s). Must be between 1,000 and 1,000,000. Must be set in increments of 1,000. Conflicts with throughput.<br>    }))<br>    cosmosdb_sql_database_containers = map(object({               # (Optional) Creates containers inside sql database<br>      cosmosdb_sql_container_name                  = string       # (Required) Specifies the name of the Cosmos DB SQL Container. Changing this forces a new resource to be created.<br>      cosmosdb_sql_container_partition_key_path    = list(string) # (Required) Define a partition key. Changing this forces a new resource to be created.<br>      cosmosdb_sql_container_partition_key_version = number       # (Optional) Define a partition key version. Changing this forces a new resource to be created. Possible values are 1and 2. This should be set to 2 in order to use large partition keys.<br>      cosmosdb_sql_container_throughput            = number       # (Optional) The throughput of SQL container (RU/s). Must be set in increments of 100. The minimum value is 400. <br>      cosmosdb_sql_container_unique_key = list(object({           # (Optional) One or more unique_key can be created<br>        unique_key_paths = list(string)                           # (Required) A list of paths to use for this unique key.<br>      }))<br>      cosmosdb_sql_container_autoscale_settings = object({ # (Optional) Define autoscale settings. <br>        autoscale_settings_max_throughput = number         # (Optional) The maximum throughput of the SQL container (RU/s). Must be between 1,000 and 1,000,000. Must be set in increments of 1,000. <br>      })<br>      cosmosdb_sql_container_indexing_policy = object({ #(Optional) Indexing_policy<br>        indexing_policy_indexing_mode = string          # (Optional) Indicates the indexing mode. Possible values include: consistent and none. Defaults to consistent.<br>        indexing_policy_included_path = list(object({   # (Optional) One or more included_path can be provided.<br>          path = string                                 # (Required) Path for which the indexing behaviour applies to.<br>        }))<br>        indexing_policy_excluded_path = list(object({ # (Optional) One or more excluded_path can be provided.<br>          path = string                               # (Required) Path for which the indexing behaviour applies to.<br>        }))<br>        indexing_policy_composite_index = list(object({ # (Required) One or more composite_index blocks can be provided.<br>          index = list(object({                         # (Required) One or more index blocks can be provided.<br>            index_path  = string                        # (Required) Path for which the indexing behaviour applies to.<br>            index_order = string                        # (Required) Order of the index. Possible values are Ascending or Descending.<br>          }))<br>        }))<br>        indexing_policy_spatial_index = list(object({ # (Required) One or more spatial_index blocks can be provided.<br>          spatial_index_path = string                 # (Required) Path for which the indexing behaviour applies to. According to the service design, all spatial types including LineString, MultiPolygon, Point, and Polygon will be applied to the path.<br>        }))<br>      })<br>      cosmosdb_sql_container_default_ttl            = string # (Optional) The default time to live of SQL container. If missing, items are not expired automatically. If present and the value is set to -1, it is equal to infinity, and items don’t expire by default. If present and the value is set to some number n – items will expire n seconds after their last modified time.<br>      cosmosdb_sql_container_analytical_storage_ttl = string # (Optional) The default time to live of Analytical Storage for this SQL container. If present and the value is set to -1, it is equal to infinity, and items don’t expire by default. If present and the value is set to some number n – items will expire n seconds after their last modified time.<br>      cosmosdb_sql_container_conflict_resolution_policy = object({<br>        conflict_resolution_policy_mode                          = string # (Required) Indicates the conflict resolution mode. Possible values include: LastWriterWins, Custom.<br>        conflict_resolution_policy_conflict_resolution_path      = string # (Optional) The conflict resolution path in the case of LastWriterWins mode.<br>        conflict_resolution_policy_conflict_resolution_procedure = string # (Optional) The procedure to resolve conflicts in the case of Custom mode.<br>      })<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | (Optional) The creation mode for the CosmosDB Account. Possible values are Default and Restore. Changing this forces a new resource to be created. Note. create\_mode only works when backup.type is Continuous. | `string` | `null` | no |
| <a name="input_default_identity_type"></a> [default\_identity\_type](#input\_default\_identity\_type) | (Optional) The default identity for accessing Key Vault. Possible values are FirstPartyIdentity, SystemAssignedIdentity or UserAssignedIdentity. | `string` | `null` | no |
| <a name="input_enable_automatic_failover"></a> [enable\_automatic\_failover](#input\_enable\_automatic\_failover) | (Optional) Enable automatic failover for this Cosmos DB account. | `bool` | `false` | no |
| <a name="input_enable_free_tier"></a> [enable\_free\_tier](#input\_enable\_free\_tier) | (Optional) Enable the Free Tier pricing option for this Cosmos DB account. Defaults to false. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_enable_multiple_write_locations"></a> [enable\_multiple\_write\_locations](#input\_enable\_multiple\_write\_locations) | (Optional) Enable multiple write locations for this Cosmos DB account. | `bool` | `false` | no |
| <a name="input_enable_restore"></a> [enable\_restore](#input\_enable\_restore) | #(Optional) Whether to enable restore or no | `bool` | `false` | no |
| <a name="input_ip_range_filter"></a> [ip\_range\_filter](#input\_ip\_range\_filter) | (Optional) CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for a given database account. IP addresses/ranges must be comma separated and must not contain any spaces. | `list(string)` | `[]` | no |
| <a name="input_is_key_vault_cmk_encryption_in_use"></a> [is\_key\_vault\_cmk\_encryption\_in\_use](#input\_is\_key\_vault\_cmk\_encryption\_in\_use) | Whether to use Key Vault Key ID for CMK encryption for cosmos db resource resources | `bool` | `null` | no |
| <a name="input_is_virtual_network_filter_enabled"></a> [is\_virtual\_network\_filter\_enabled](#input\_is\_virtual\_network\_filter\_enabled) | (Optional) Enables virtual network filtering for this Cosmos DB account. | `bool` | `null` | no |
| <a name="input_is_virtual_network_subnets_allowed"></a> [is\_virtual\_network\_subnets\_allowed](#input\_is\_virtual\_network\_subnets\_allowed) | Configures the virtual network subnets allowed to access this Cosmos DB account | `bool` | `null` | no |
| <a name="input_is_zone_redundant"></a> [is\_zone\_redundant](#input\_is\_zone\_redundant) | (Optional) Is database account zone redundant | `bool` | `false` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | (Required) Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB, MongoDB and Parse. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | (Optional) Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Defaults to false. Can be set only when using the SQL API. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"westus2"` | no |
| <a name="input_managed_identity_ids"></a> [managed\_identity\_ids](#input\_managed\_identity\_ids) | (Required) A list of User Managed Identity ID's which should be assigned. | `list(string)` | `null` | no |
| <a name="input_managed_identity_type"></a> [managed\_identity\_type](#input\_managed\_identity\_type) | (Required) Possible values are `null`, `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned` | `string` | `null` | no |
| <a name="input_network_acl_bypass_for_azure_services"></a> [network\_acl\_bypass\_for\_azure\_services](#input\_network\_acl\_bypass\_for\_azure\_services) | (Optional) If Azure services can bypass ACLs. Defaults to false. | `bool` | `false` | no |
| <a name="input_network_acl_bypass_ids"></a> [network\_acl\_bypass\_ids](#input\_network\_acl\_bypass\_ids) | (Optional) The list of resource Ids for Network Acl Bypass for this Cosmos DB account. | `list(string)` | `null` | no |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | (Optional) Specifies the Offer Type to use for this CosmosDB Account; currently, this can only be set to Standard. | `string` | `"Standard"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether or not public network access is allowed for this CosmosDB account. Defaults to true. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which the CosmosDB Account is created. Changing this forces a new resource to be created. | `string` | `"rg-test-westus2-01"` | no |
| <a name="input_restore"></a> [restore](#input\_restore) | #(Optional) If enable\_restore is true, restore block needs to set | <pre>object({                               #(Optional) A restore block as defined below<br>    restore_source_cosmosdb_account_id = string #(Required) The resource ID of the restorable database account from which the restore has to be initiated. The example is /subscriptions/{subscriptionId}/providers/Microsoft.DocumentDB/locations/{location}/restorableDatabaseAccounts/{restorableDatabaseAccountName}. Changing this forces a new resource to be created.<br>    restore_restore_timestamp_in_utc   = string #(Required) The creation time of the database or the collection (Datetime Format RFC 3339). Changing this forces a new resource to be created.<br>    restore_database = object({<br>      database_name             = string       #(Required) The database name for the restore request. Changing this forces a new resource to be created.<br>      database_collection_names = list(string) # (Optional) A list of the collection names for the restore request. Changing this forces a new resource to be created.<br>    })<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_total_throughput_limit_capacity"></a> [total\_throughput\_limit\_capacity](#input\_total\_throughput\_limit\_capacity) | (Required) The total throughput limit imposed on this Cosmos DB account (RU/s). Possible values are at least -1. -1 means no limit. | `number` | n/a | yes |
| <a name="input_virtual_network_subnets"></a> [virtual\_network\_subnets](#input\_virtual\_network\_subnets) | (Optional) Subnets for virtual\_network\_rule. If is\_virtual\_network\_subnets\_allowed then it is required. | <pre>list(object({<br>    subnet_name                          = string # (Required) Subnet name for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required. <br>    virtual_network_name                 = string # Vnet name for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required.<br>    resource_group_name                  = string # Subnet RG name for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required.<br>    ignore_missing_vnet_service_endpoint = bool   # If set to true, the specified subnet will be added as a virtual network rule even if its CosmosDB service endpoint is not active.<br>  }))</pre> | `null` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cosmons_db_account_endpoint"></a> [cosmons\_db\_account\_endpoint](#output\_cosmons\_db\_account\_endpoint) | The endpoint of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_id"></a> [cosmons\_db\_account\_id](#output\_cosmons\_db\_account\_id) | The ID of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_kind"></a> [cosmons\_db\_account\_kind](#output\_cosmons\_db\_account\_kind) | The kind of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_primary_key"></a> [cosmons\_db\_account\_primary\_key](#output\_cosmons\_db\_account\_primary\_key) | The primary\_key of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_primary_readonly_key"></a> [cosmons\_db\_account\_primary\_readonly\_key](#output\_cosmons\_db\_account\_primary\_readonly\_key) | The primary\_readonly\_key of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_primary_readonly_sql_connection_string"></a> [cosmons\_db\_account\_primary\_readonly\_sql\_connection\_string](#output\_cosmons\_db\_account\_primary\_readonly\_sql\_connection\_string) | The primary\_readonly\_sql\_connection\_string of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_primary_sql_connection_string"></a> [cosmons\_db\_account\_primary\_sql\_connection\_string](#output\_cosmons\_db\_account\_primary\_sql\_connection\_string) | The primary\_sql\_connection\_string of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_read_endpoints"></a> [cosmons\_db\_account\_read\_endpoints](#output\_cosmons\_db\_account\_read\_endpoints) | The read\_endpoints of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_secondary_key"></a> [cosmons\_db\_account\_secondary\_key](#output\_cosmons\_db\_account\_secondary\_key) | The secondary\_key of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_secondary_readonly_key"></a> [cosmons\_db\_account\_secondary\_readonly\_key](#output\_cosmons\_db\_account\_secondary\_readonly\_key) | The secondary\_readonly\_key of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_secondary_readonly_sql_connection_string"></a> [cosmons\_db\_account\_secondary\_readonly\_sql\_connection\_string](#output\_cosmons\_db\_account\_secondary\_readonly\_sql\_connection\_string) | The secondary\_readonly\_sql\_connection\_string of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_secondary_sql_connection_string"></a> [cosmons\_db\_account\_secondary\_sql\_connection\_string](#output\_cosmons\_db\_account\_secondary\_sql\_connection\_string) | The secondary\_sql\_connection\_string of the cosmons\_db\_account. |
| <a name="output_cosmons_db_account_write_endpoints"></a> [cosmons\_db\_account\_write\_endpoints](#output\_cosmons\_db\_account\_write\_endpoints) | The write\_endpoints of the cosmons\_db\_account. |
| <a name="output_cosmos_db_account_name"></a> [cosmos\_db\_account\_name](#output\_cosmos\_db\_account\_name) | The name of the cosmons\_db\_account. |
| <a name="output_cosmosdb_sql_container_output"></a> [cosmosdb\_sql\_container\_output](#output\_cosmosdb\_sql\_container\_output) | The ID of the CosmosDB SQL Container output values |
| <a name="output_cosmosdb_sql_database_output"></a> [cosmosdb\_sql\_database\_output](#output\_cosmosdb\_sql\_database\_output) | The ID of the CosmosDB SQL Database output values |

#### The following resources are created by this module:


- resource.azurerm_cosmosdb_account.cosmons_db_account (/usr/agent/azp/_work/1/s/amn-az-tfm-cosmosdb/main.tf#96)
- resource.azurerm_cosmosdb_sql_container.cosmosdb_sql_container (/usr/agent/azp/_work/1/s/amn-az-tfm-cosmosdb/main.tf#238)
- resource.azurerm_cosmosdb_sql_database.cosmosdb_sql_database (/usr/agent/azp/_work/1/s/amn-az-tfm-cosmosdb/main.tf#216)
- data source.azurerm_key_vault.key_vault (/usr/agent/azp/_work/1/s/amn-az-tfm-cosmosdb/main.tf#73)
- data source.azurerm_key_vault_key.key_vault_key (/usr/agent/azp/_work/1/s/amn-az-tfm-cosmosdb/main.tf#79)
- data source.azurerm_subnet.subnet (/usr/agent/azp/_work/1/s/amn-az-tfm-cosmosdb/main.tf#85)


## Example Scenario

Create cosmosdb <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create cosmosdb

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
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "cosmons_db_account" {
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  # version = "1.0.0"

  # By default, this module will not create a resource group
  # provide a name to use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 
  location = var.location

  cosmos_db_account_name = var.cosmos_db_account_name
  kind                   = var.kind
  offer_type             = var.offer_type

  # Enable Analytical Storage option for this Cosmos DB account.
  analytical_storage_enabled = var.analytical_storage_enabled
  # The schema type of the Analytical Storage for this Cosmos DB account.
  analytical_storage_schema_type = var.analytical_storage_schema_type

  # The total throughput limit imposed on this Cosmos DB account (RU/s).
  total_throughput_limit_capacity = var.total_throughput_limit_capacity

  # Whether or not public network access is allowed for this CosmosDB account.
  public_network_access_enabled = var.public_network_access_enabled

  # Enable automatic failover for this Cosmos DB account.
  enable_automatic_failover = var.enable_automatic_failover

  # Enable multiple write locations for this Cosmos DB account.
  enable_multiple_write_locations = var.enable_multiple_write_locations

  # Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled

  # Whether Cosmos DB is zone redundant or not
  is_zone_redundant = var.is_zone_redundant

  # Adding TAG's to your Azure resources (Required)
  tags = var.tags

  # Enable the Free Tier pricing option for this Cosmos DB account.
  enable_free_tier = var.enable_free_tier

  # The Type of Managed Identity assigned to this Cosmos account.
  managed_identity_type = var.managed_identity_type
  # Specifies a list of User Assigned Managed Identity IDs to be assigned to this Cosmos Account.
  managed_identity_ids = var.managed_identity_ids

  # Configures the capabilities to be enabled for this Cosmos DB account
  cosmosdb_account_capabilities = var.cosmosdb_account_capabilities

  # Used to define the consistency policy for this CosmosDB account
  # The Consistency Level to use for this CosmosDB Account
  cosmosdb_account_consistency_policy_consistency_level = var.cosmosdb_account_consistency_policy_consistency_level
  # When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. 
  cosmosdb_account_consistency_policy_max_interval_in_seconds = var.cosmosdb_account_consistency_policy_max_interval_in_seconds
  # When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated.
  cosmosdb_account_consistency_policy_max_staleness_prefix = var.cosmosdb_account_consistency_policy_max_staleness_prefix

  # The creation mode for the CosmosDB Account.
  create_mode = var.create_mode

  # The default identity for accessing Key Vault.
  default_identity_type = var.default_identity_type

  # CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for a given database account. IP addresses/ranges must be comma separated and must not contain any spaces.
  ip_range_filter = var.ip_range_filter

  # Enables virtual network filtering for this Cosmos DB account.
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled

  # A versionless Key Vault Key ID for CMK encryption.
  is_key_vault_cmk_encryption_in_use             = var.is_key_vault_cmk_encryption_in_use
  cosmosdb_account_key_vault_name                = var.cosmosdb_account_key_vault_name
  cosmosdb_account_key_vault_resource_group_name = var.cosmosdb_account_key_vault_resource_group_name
  cosmosdb_account_key_vault_key_name            = var.cosmosdb_account_key_vault_key_name

  # Configures the virtual network subnets allowed to access this Cosmos DB account
  is_virtual_network_subnets_allowed = var.is_virtual_network_subnets_allowed
  # if is_virtual_network_subnets_allowed is true then user need to provide a list of subnets with it's details such as ignore_missing_vnet_service_endpoint, subnet name, vnet and rg and 
  virtual_network_subnets = var.virtual_network_subnets

  # Configures the backup for this Cosmos DB account
  cosmosdb_account_backup = var.cosmosdb_account_backup

  # If Azure services can bypass ACLs.
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services

  # The list of resource Ids for Network Acl Bypass for this Cosmos DB account.
  network_acl_bypass_ids = var.network_acl_bypass_ids

  # Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Defaults to false. Can be set only when using the SQL API.
  local_authentication_disabled = var.local_authentication_disabled

  # If we can enable Restore on cosmos DB account.
  enable_restore = var.enable_restore

  # If enable_restore is true, restore block needs to set
  restore = var.restore

  # A cors_rule block.
  cors_rule = var.cors_rule

  # CosmosDB SQL Database variables
  cosmosdb_sql_database_variables = var.cosmosdb_sql_database_variables
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
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
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->