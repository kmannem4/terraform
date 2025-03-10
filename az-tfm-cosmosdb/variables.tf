variable "resource_group_name" {
  description = "(Required) The name of the resource group in which the CosmosDB Account is created. Changing this forces a new resource to be created."
  default     = "rg-test-westus2-01"
  type        = string
}

variable "location" {
  description = " (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "westus2"
  type        = string
}

variable "cosmos_db_account_name" {
  description = "(Required) Specifies the name of this CosmosDB Account."
  default     = ""
  type        = string
}

variable "offer_type" {
  description = "(Optional) Specifies the Offer Type to use for this CosmosDB Account; currently, this can only be set to Standard."
  default     = "Standard"
  type        = string
}

variable "analytical_storage_schema_type" {
  description = "(Required) The schema type of the Analytical Storage for this Cosmos DB account. Possible values are FullFidelity and WellDefined."
  default     = null
  type        = string
  validation {
    condition     = var.analytical_storage_schema_type == null || var.analytical_storage_schema_type == "FullFidelity" || var.analytical_storage_schema_type == "WellDefined"
    error_message = "Invalid 'analytical_storage_schema_type' Valid values are null, FullFidelity , and WellDefined."
  }
}

variable "total_throughput_limit_capacity" {
  description = "(Required) The total throughput limit imposed on this Cosmos DB account (RU/s). Possible values are at least -1. -1 means no limit."
  type        = number
}

variable "kind" {
  type        = string
  description = "(Required) Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB, MongoDB and Parse. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created."
  validation {
    # condition     = var.kind == "GlobalDocumentDB" || var.kind == "MongoDB" || var.kind == "Parse"
    condition     = var.kind == "GlobalDocumentDB"
    error_message = "Invalid 'kind' Valid values are GlobalDocumentDB."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Whether or not public network access is allowed for this CosmosDB account. Defaults to true."
  default     = true
}

variable "enable_automatic_failover" {
  type        = bool
  description = "(Optional) Enable automatic failover for this Cosmos DB account."
  default     = false
}

variable "enable_multiple_write_locations" {
  type        = bool
  description = "(Optional) Enable multiple write locations for this Cosmos DB account."
  default     = false
}

variable "access_key_metadata_writes_enabled" {
  type        = bool
  description = "(Optional) Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?"
  default     = false
}

variable "is_zone_redundant" {
  type        = bool
  description = "(Optional) Is database account zone redundant"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_free_tier" {
  type        = bool
  description = "(Optional) Enable the Free Tier pricing option for this Cosmos DB account. Defaults to false. Changing this forces a new resource to be created."
  default     = false
}

variable "managed_identity_type" {
  description = "(Required) Possible values are `null`, `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = null
  type        = string
}

variable "managed_identity_ids" {
  description = "(Required) A list of User Managed Identity ID's which should be assigned."
  default     = null
  type        = list(string)
}

variable "cosmosdb_account_capabilities" {
  description = "(Optional) The capabilities which should be enabled for this Cosmos DB account."
  default     = null
  type = list(object({
    capabilities_name = string
  }))
}

variable "cosmosdb_account_consistency_policy_consistency_level" {
  description = "(Required) Configures the database consistency policy level."
  default     = "Session"
  type        = string
  validation {
    condition     = var.cosmosdb_account_consistency_policy_consistency_level == "BoundedStaleness" || var.cosmosdb_account_consistency_policy_consistency_level == "Eventual" || var.cosmosdb_account_consistency_policy_consistency_level == "Session" || var.cosmosdb_account_consistency_policy_consistency_level == "Strong " || var.cosmosdb_account_consistency_policy_consistency_level == "ConsistentPrefix "
    error_message = "Invalid 'consistency_level' Valid values are BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix."
  }
}

variable "cosmosdb_account_consistency_policy_max_interval_in_seconds" {
  description = "(Optional) Configures the database consistency policy max_interval_in_seconds."
  default     = 5
  type        = number
  validation {
    condition     = var.cosmosdb_account_consistency_policy_max_interval_in_seconds == null || (var.cosmosdb_account_consistency_policy_max_interval_in_seconds >= 5 && var.cosmosdb_account_consistency_policy_max_interval_in_seconds <= 1000)
    error_message = "If max_interval_in_seconds is either null or between 5 and 86400 (inclusive), the condition is true."
  }
}

variable "cosmosdb_account_consistency_policy_max_staleness_prefix" {
  description = "(Optional) Configures the database consistency policy max_staleness_prefix."
  default     = 100
  type        = number
  validation {
    condition     = var.cosmosdb_account_consistency_policy_max_staleness_prefix == null || (var.cosmosdb_account_consistency_policy_max_staleness_prefix >= 10 && var.cosmosdb_account_consistency_policy_max_staleness_prefix <= 2147483647)
    error_message = "If max_interval_in_seconds is either null or between 10 - 2147483647 (inclusive), the condition is true."
  }
}

variable "create_mode" {
  description = "(Optional) The creation mode for the CosmosDB Account. Possible values are Default and Restore. Changing this forces a new resource to be created. Note. create_mode only works when backup.type is Continuous."
  type        = string
  default     = null
  validation {
    condition     = var.create_mode == "Default" || var.create_mode == "Restore" || var.create_mode == null
    error_message = "Possible values are null, Default and Restore"
  }
}

variable "default_identity_type" {
  description = "(Optional) The default identity for accessing Key Vault. Possible values are FirstPartyIdentity, SystemAssignedIdentity or UserAssignedIdentity."
  type        = string
  default     = null
  validation {
    condition     = var.default_identity_type == "FirstPartyIdentity" || var.default_identity_type == "SystemAssignedIdentity" || var.default_identity_type == "UserAssignedIdentity" || var.default_identity_type == null
    error_message = "Possible values are null, FirstPartyIdentity, SystemAssignedIdentity or UserAssignedIdentity "
  }
}

variable "ip_range_filter" {
  description = "(Optional) CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for a given database account. IP addresses/ranges must be comma separated and must not contain any spaces."
  type        = list(string)
  default     = []
}

variable "analytical_storage_enabled" {
  description = "(Optional) Enable Analytical Storage option for this Cosmos DB account. Defaults to false. Enabling and then disabling analytical storage forces a new resource to be created."
  type        = bool
  default     = null
}

variable "is_virtual_network_filter_enabled" {
  description = "(Optional) Enables virtual network filtering for this Cosmos DB account."
  type        = bool
  default     = null
}

variable "is_key_vault_cmk_encryption_in_use" {
  description = "Whether to use Key Vault Key ID for CMK encryption for cosmos db resource resources"
  default     = null
  type        = bool
}

variable "cosmosdb_account_key_vault_name" {
  description = "(Optional) A versionless Key Vault Name for CMK encryption. If is_key_vault_cmk_encryption_in_use is true then this is required."
  type        = string
  default     = null
}

variable "cosmosdb_account_key_vault_resource_group_name" {
  description = "(Optional) A versionless Key Vault Resource Group Name for CMK encryption. If is_key_vault_cmk_encryption_in_use is true then this is required."
  type        = string
  default     = null
}

variable "cosmosdb_account_key_vault_key_name" {
  description = "(Optional) A versionless Key Vault Key Name for CMK encryption. If is_key_vault_cmk_encryption_in_use is true then this is required."
  type        = string
  default     = null
}

variable "is_virtual_network_subnets_allowed" {
  description = "Configures the virtual network subnets allowed to access this Cosmos DB account"
  default     = null
  type        = bool
}

variable "virtual_network_subnets" {
  description = "(Optional) Subnets for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required."
  default     = null
  type = list(object({
    subnet_name                          = string # (Required) Subnet name for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required. 
    virtual_network_name                 = string # Vnet name for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required.
    resource_group_name                  = string # Subnet RG name for virtual_network_rule. If is_virtual_network_subnets_allowed then it is required.
    ignore_missing_vnet_service_endpoint = bool   # If set to true, the specified subnet will be added as a virtual network rule even if its CosmosDB service endpoint is not active.
  }))
}

variable "cosmosdb_account_backup" {
  description = "(Optional) The backup which hould be enabled for this Cosmos DB account."
  default     = null
  type = object({
    backup_type                = string #  (Required) The type of the backup. Possible values are Continuous and Periodic. Migration of Periodic to Continuous is one-way, changing Continuous to Periodic forces a new resource to be created. 
    backup_interval_in_minutes = number #  (Optional) The interval in minutes between two backups. This is configurable only when type is Periodic. Possible values are between 60 and 1440.
    backup_retention_in_hours  = number #  (Optional) The time in hours that each backup is retained. This is configurable only when type is Periodic. Possible values are between 8 and 720.
    backup_storage_redundancy  = string #  (Optional) The storage redundancy is used to indicate the type of backup residency. This is configurable only when type is Periodic. Possible values are Geo, Local and Zone.
  })
}

variable "network_acl_bypass_for_azure_services" {
  description = "(Optional) If Azure services can bypass ACLs. Defaults to false."
  default     = false
  type        = bool
}

variable "network_acl_bypass_ids" {
  description = "(Optional) The list of resource Ids for Network Acl Bypass for this Cosmos DB account."
  default     = null
  type        = list(string)
}

variable "local_authentication_disabled" {
  description = "(Optional) Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Defaults to false. Can be set only when using the SQL API."
  default     = null
  type        = bool
}


variable "enable_restore" {
  description = "#(Optional) Whether to enable restore or no"
  default     = false
  type        = bool
}

variable "restore" {
  description = "#(Optional) If enable_restore is true, restore block needs to set"
  default     = null
  type = object({                               #(Optional) A restore block as defined below
    restore_source_cosmosdb_account_id = string #(Required) The resource ID of the restorable database account from which the restore has to be initiated. The example is /subscriptions/{subscriptionId}/providers/Microsoft.DocumentDB/locations/{location}/restorableDatabaseAccounts/{restorableDatabaseAccountName}. Changing this forces a new resource to be created.
    restore_restore_timestamp_in_utc   = string #(Required) The creation time of the database or the collection (Datetime Format RFC 3339). Changing this forces a new resource to be created.
    restore_database = object({
      database_name             = string       #(Required) The database name for the restore request. Changing this forces a new resource to be created.
      database_collection_names = list(string) # (Optional) A list of the collection names for the restore request. Changing this forces a new resource to be created.
    })
  })
}

variable "cors_rule" {
  description = "#(Optional) Cross-Origin Resource Sharing (CORS) is an HTTP feature that enables a web application running under one domain to access resources in another domain. A cors_rule block as defined below."
  default     = null
  type = object({                               #(Optional) A cors_rule block as defined below.
    cors_rule_allowed_headers    = list(string) #(Required) A list of headers that are allowed to be a part of the cross-origin request.
    cors_rule_allowed_methods    = list(string) #(Required) A list of HTTP headers that are allowed to be executed by the origin. Valid options are DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT or PATCH.
    cors_rule_allowed_origins    = list(string) #(Required) A list of origin domains that will be allowed by CORS.
    cors_rule_exposed_headers    = list(string) #(Required) A list of response headers that are exposed to CORS clients.
    cors_rule_max_age_in_seconds = number       #(Required) The number of seconds the client should cache a preflight response.
  })
}

variable "cosmosdb_sql_database_variables" {
  description = "CosmosDB SQL Database"
  type = map(object({
    cosmosdb_sql_database_name       = string                # (Required) Specifies the name of the Cosmos DB SQL Database. Changing this forces a new resource to be created.
    cosmosdb_sql_database_throughput = number                # (Optional) The throughput of SQL database (RU/s). Must be set in increments of 100. The minimum value is 400. This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.
    cosmosdb_sql_database_autoscale_settings = list(object({ # (Optional) This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.
      autoscale_settings_max_throughput = number             # (Optional) The maximum throughput of the SQL database (RU/s). Must be between 1,000 and 1,000,000. Must be set in increments of 1,000. Conflicts with throughput.
    }))
    cosmosdb_sql_database_containers = map(object({               # (Optional) Creates containers inside sql database
      cosmosdb_sql_container_name                  = string       # (Required) Specifies the name of the Cosmos DB SQL Container. Changing this forces a new resource to be created.
      cosmosdb_sql_container_partition_key_path    = list(string) # (Required) Define a partition key. Changing this forces a new resource to be created.
      cosmosdb_sql_container_partition_key_version = number       # (Optional) Define a partition key version. Changing this forces a new resource to be created. Possible values are 1and 2. This should be set to 2 in order to use large partition keys.
      cosmosdb_sql_container_throughput            = number       # (Optional) The throughput of SQL container (RU/s). Must be set in increments of 100. The minimum value is 400. 
      cosmosdb_sql_container_unique_key = list(object({           # (Optional) One or more unique_key can be created
        unique_key_paths = list(string)                           # (Required) A list of paths to use for this unique key.
      }))
      cosmosdb_sql_container_autoscale_settings = object({ # (Optional) Define autoscale settings. 
        autoscale_settings_max_throughput = number         # (Optional) The maximum throughput of the SQL container (RU/s). Must be between 1,000 and 1,000,000. Must be set in increments of 1,000. 
      })
      cosmosdb_sql_container_indexing_policy = object({ #(Optional) Indexing_policy
        indexing_policy_indexing_mode = string          # (Optional) Indicates the indexing mode. Possible values include: consistent and none. Defaults to consistent.
        indexing_policy_included_path = list(object({   # (Optional) One or more included_path can be provided.
          path = string                                 # (Required) Path for which the indexing behaviour applies to.
        }))
        indexing_policy_excluded_path = list(object({ # (Optional) One or more excluded_path can be provided.
          path = string                               # (Required) Path for which the indexing behaviour applies to.
        }))
        indexing_policy_composite_index = list(object({ # (Required) One or more composite_index blocks can be provided.
          index = list(object({                         # (Required) One or more index blocks can be provided.
            index_path  = string                        # (Required) Path for which the indexing behaviour applies to.
            index_order = string                        # (Required) Order of the index. Possible values are Ascending or Descending.
          }))
        }))
        indexing_policy_spatial_index = list(object({ # (Required) One or more spatial_index blocks can be provided.
          spatial_index_path = string                 # (Required) Path for which the indexing behaviour applies to. According to the service design, all spatial types including LineString, MultiPolygon, Point, and Polygon will be applied to the path.
        }))
      })
      cosmosdb_sql_container_default_ttl            = string # (Optional) The default time to live of SQL container. If missing, items are not expired automatically. If present and the value is set to -1, it is equal to infinity, and items don’t expire by default. If present and the value is set to some number n – items will expire n seconds after their last modified time.
      cosmosdb_sql_container_analytical_storage_ttl = string # (Optional) The default time to live of Analytical Storage for this SQL container. If present and the value is set to -1, it is equal to infinity, and items don’t expire by default. If present and the value is set to some number n – items will expire n seconds after their last modified time.
      cosmosdb_sql_container_conflict_resolution_policy = object({
        conflict_resolution_policy_mode                          = string # (Required) Indicates the conflict resolution mode. Possible values include: LastWriterWins, Custom.
        conflict_resolution_policy_conflict_resolution_path      = string # (Optional) The conflict resolution path in the case of LastWriterWins mode.
        conflict_resolution_policy_conflict_resolution_procedure = string # (Optional) The procedure to resolve conflicts in the case of Custom mode.
      })
    }))
  }))
}
