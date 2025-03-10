output "key_vault_id" {
  description = "Key Vault ID."
  value       = module.key_vault.key_vault_id
}

output "key_vault" {
  description = "Key vault"
  value       = module.key_vault.key_vault
}

output "key_vault_name" {
  description = "key vault created."
  value       = module.key_vault.key_vault_name
}

output "key_vault_location" {
  description = "key vault created."
  value       = module.key_vault.key_vault_location
}

output "key_vault_purge_protection_enabled" {
  description = "key vault created."
  value       = module.key_vault.key_vault_purge_protection_enabled
}

output "key_vault_soft_delete_retention_days" {
  description = "key vault created."
  value       = module.key_vault.key_vault_soft_delete_retention_days
}

output "key_vault_sku_name" {
  description = "key vault SKU name."
  value       = module.key_vault.key_vault_sku_name
}

output "key_vault_enabled_for_template_deployment" {
  description = "value of key vault enabled_for_template_deployment"
  value       = module.key_vault.key_vault_enabled_for_template_deployment
}

output "key_vault_enabled_for_disk_encryption" {
  description = "value of key vault enabled_for_disk_encryption"
  value       = module.key_vault.key_vault_enabled_for_disk_encryption
}

output "key_vault_enable_rbac_authorization" {
  description = "value of key vault enable_rbac_authorization"
  value       = module.key_vault.key_vault_enable_rbac_authorization
}
output "key_vault_enabled_for_deployment" {
  description = "value of key vault enabled_for_deployment"
  value       = module.key_vault.key_vault_enabled_for_deployment
}

output "key_vault_public_network_access_enabled" {
  description = "value of key vault public_network_access_enabled"
  value       = module.key_vault.key_vault_public_network_access_enabled
}
