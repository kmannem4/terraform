resource "azurerm_data_protection_backup_policy_blob_storage" "data_protection_backup_policy_blob_storage" {
  name                                   = var.backup_policy_blob_storage_name
  vault_id                               = var.vault_id
  backup_repeating_time_intervals        = var.backup_repeating_time_intervals
  operational_default_retention_duration = var.operational_default_retention_duration
  vault_default_retention_duration       = var.vault_default_retention_duration
  time_zone                              = var.time_zone

  dynamic "retention_rule" {
    for_each = var.retention_rule == null ? [] : var.retention_rule
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      dynamic "criteria" {
        for_each = retention_rule.value.criteria == null ? [] : retention_rule.value.criteria
        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_month          = criteria.value.days_of_month
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }
      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle == null ? [] : retention_rule.value.life_cycle
        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_blob_storage" "data_protection_backup_instance_blob_storage" {
  depends_on = [azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage]

  name                            = var.backup_instance_blob_storage_name
  vault_id                        = var.vault_id
  location                        = var.location
  storage_account_id              = var.storage_account_id
  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.id
  storage_account_container_names = var.storage_account_container_names
}
