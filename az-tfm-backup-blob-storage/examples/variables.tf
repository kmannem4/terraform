variable "location" {
  description = "The Azure Region where the backup vault should exist. Changing this forces a new backup vault to be created."
  type        = string
  default     = ""
}

variable "description" {
  description = "Description of the resource. Changing this forces a new backup vault to be created."
  type        = string
  default     = ""
}

variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}

variable "datastore_type" {
  description = "Specifies the type of the data store."
  type        = string
  default     = ""
}

variable "redundancy" {
  description = "Specifies the backup storage redundancy."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "backup_repeating_time_intervals" {
  type = list(string)
}

variable "operational_default_retention_duration" {
  type = string
}

variable "vault_default_retention_duration" {
  type = string
}

variable "time_zone" {
  type = string
}

variable "retention_rule" {
  type = list(object({
    name     = string
    priority = string
    criteria = list(object({
      absolute_criteria      = string
      days_of_month          = string
      days_of_week           = string
      months_of_year         = string
      scheduled_backup_times = string
      weeks_of_month         = string
    }))
    life_cycle = list(object({
      data_store_type = string
      duration        = string
    }))
  }))
}

#storage account
variable "skuname" {
  description = "The SKU of the storage account."
  type        = string
  default     = "Standard_LRS"
}

variable "account_kind" {
  description = "The Kind of the storage account."
  type        = string
  default     = "StorageV2"
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for the storage account."
  type        = bool
  default     = true
}

variable "blob_soft_delete_retention_days" {
  description = "The number of days that soft-deleted blob data should be retained."
  type        = number
  default     = 31
}

variable "container_soft_delete_retention_days" {
  description = "The number of days that soft-deleted container data should be retained."
  type        = number
  default     = 31
}

variable "containers_list" {
  description = "List of containers to create within the storage account."
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []
}

variable "role_definition_name" {
  description = "The name of the role definition to assign to the managed identity."
  type        = string
}
