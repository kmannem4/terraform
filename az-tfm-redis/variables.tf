variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Location of the resource group."
  type        = string
}

variable "subnet_id" {
  type        = string
  description = "subnet id of redis to be created"
  default     = null
}

variable "private_static_ip_address" {
  type        = string
  description = "private static ip address of redis to be created"
  default     = null
}

variable "redis_vars" {
  description = "Redis variables"
  type = map(object({
    name                               = string
    capacity                           = number
    family                             = string
    sku_name                           = string
    access_keys_authentication_enabled = optional(bool)
    non_ssl_port_enabled               = optional(bool)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    minimum_tls_version = optional(string)
    patch_schedule = optional(object({
      day_of_week        = string
      start_hour_utc     = optional(string)
      maintenance_window = optional(string)
    }))
    zones                         = optional(list(string))
    public_network_access_enabled = optional(bool)
    redis_configuration = optional(object({
      aof_backup_enabled                      = optional(bool)
      aof_storage_connection_string_0         = optional(string)
      aof_storage_connection_string_1         = optional(string)
      authentication_enabled                  = optional(bool)
      active_directory_authentication_enabled = optional(bool)
      maxmemory_reserved                      = optional(number)
      maxmemory_delta                         = optional(number)
      maxmemory_policy                        = optional(string)
      data_persistence_authentication_method  = optional(string)
      maxfragmentationmemory_reserved         = optional(number)
      rdb_backup_enabled                      = optional(bool)
      rdb_backup_frequency                    = optional(number)
      rdb_backup_max_snapshot_count           = optional(number)
      rdb_storage_connection_string           = optional(string)
      storage_account_subscription_id         = optional(string)
      notify_keyspace_events                  = optional(string)
    }))
    replicas_per_master  = optional(number)
    replicas_per_primary = optional(number)
    redis_version        = optional(string)
    tenant_settings      = optional(map(string))
    shard_count          = optional(number)
  }))
  default = {}
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = null
}