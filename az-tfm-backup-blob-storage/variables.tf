# Purpose: Define the input variables for the module.
variable "backup_policy_blob_storage_name" {
  type = string
}

variable "vault_id" {
  type = string
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

variable "backup_instance_blob_storage_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_container_names" {
  type = list(string)
}

variable "storage_account_id" {
  type = string
}
