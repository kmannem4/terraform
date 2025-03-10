variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Resource group location"
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}

variable "managed_instance" {
  type = map(object({
    mssql_server_name              = string
    mssql_database_name            = string
    administrator_login            = string
    administrator_login_password   = string
    vcores                         = number
    storage_size_in_gb             = number
    license_type                   = string
    sku_name                       = string
    collation                      = optional(string)
    maintenance_configuration_name = optional(string)
    identity = optional(list(object({
      type         = string
      identity_ids = optional(string)
    })))
    minimum_tls_version          = optional(string)
    proxy_override               = optional(string)
    public_data_endpoint_enabled = optional(string)
    zone_redundant_enabled       = optional(string)
    storage_account_type         = optional(string)
    dns_zone_partner_id          = optional(string)
    timezone_id                  = optional(string)
    long_term_retention_policy = optional(object({
      weekly_retention  = optional(string)
      monthly_retention = optional(string)
      yearly_retention  = optional(string)
      week_of_year      = optional(string)
    }))
    short_term_retention_days = optional(string)
    point_in_time_restore = optional(object({
      source_database_id    = string
      restore_point_in_time = string
    }))

    network_config_virtual_network_name                = string
    network_config_virtual_network_resource_group_name = string
    vnet_address_space                                 = list(string)
    network_config_subnet_name                         = string
    subnet_address_prefix                              = list(string)
    delegation = optional(object({
      name = string
      service_delegation = optional(object({
        name    = string
        actions = list(string)
      }))
    }))
    nsg_inbound_rules  = optional(list(list(string)))
    nsg_outbound_rules = optional(list(list(string)))
  }))
}
