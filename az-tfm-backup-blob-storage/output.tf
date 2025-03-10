# Description: This file contains the output variables for the data protection backup policy and instance resources.
output "name" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.name
}

output "vault_id" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.vault_id
}

output "backup_repeating_time_intervals" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.backup_repeating_time_intervals
}

output "operational_default_retention_duration" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.operational_default_retention_duration
}

output "vault_default_retention_duration" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.vault_default_retention_duration
}

output "time_zone" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.time_zone
}

output "retention_rule" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.retention_rule
}

output "id" {
  value = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.id
}

output "backup_instance_blob_storage_name" {
  value = azurerm_data_protection_backup_instance_blob_storage.data_protection_backup_instance_blob_storage.name
}

output "location" {
  value = azurerm_data_protection_backup_instance_blob_storage.data_protection_backup_instance_blob_storage.location
}

output "storage_account_id" {
  value = azurerm_data_protection_backup_instance_blob_storage.data_protection_backup_instance_blob_storage.storage_account_id
}

output "backup_policy_id" {
  value = azurerm_data_protection_backup_instance_blob_storage.data_protection_backup_instance_blob_storage.backup_policy_id
}
