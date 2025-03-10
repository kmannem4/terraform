output "id" {
  description = "The ID of the Backup Vault."
  value       = azurerm_data_protection_backup_vault.backup_vault.id
}

output "backup_vault_name" {
  description = "The name of the Backup vault."
  value       = azurerm_data_protection_backup_vault.backup_vault.name
}

output "backup_vault_redundancy" {
  description = "The redundancy of the Backup vault."
  value       = azurerm_data_protection_backup_vault.backup_vault.redundancy
}

output "backup_vault_datastore_type" {
  description = "The datastore type of the Backup vault."
  value       = azurerm_data_protection_backup_vault.backup_vault.datastore_type
}

output "backup_vault_identity" {
  description = "The identity of the Backup vault."
  value       = azurerm_data_protection_backup_vault.backup_vault.identity 
}