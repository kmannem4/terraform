output "id" {
  description = "The ID of the Backup vault."
  value       = module.backup_vault.id
}

output "backup_vault_name" {
  description = "The name of the Backup vault."
  value       = module.backup_vault.backup_vault_name
}

output "backup_vault_redundancy" {
  description = "The redundancy of the Backup vault."
  value       = module.backup_vault.backup_vault_redundancy
}

output "backup_vault_datastore_type" {
  description = "The datastore type of the Backup vault."
  value       = module.backup_vault.backup_vault_datastore_type
}

output "backup_vault_identity" {
  description = "The identity of the Backup vault."
  value       = module.backup_vault.backup_vault_identity
}