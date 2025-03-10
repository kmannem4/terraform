output "key_vault_name" {
  description = "key vault created."
  value       = azurerm_key_vault.key_vault.name
}

output "key_vault_resource_group_name" {
  description = "key vault created."
  value       = azurerm_key_vault.key_vault.resource_group_name
}

output "key_vault_location" {
  description = "key vault created."
  value       = azurerm_key_vault.key_vault.location
}

output "key_vault_purge_protection_enabled" {
  description = "key vault created."
  value       = azurerm_key_vault.key_vault.purge_protection_enabled
}

output "key_vault_soft_delete_retention_days" {
  description = "key vault created."
  value       = azurerm_key_vault.key_vault.soft_delete_retention_days
}

output "key_vault_sku_name" {
  description = "key vault SKU name."
  value       = azurerm_key_vault.key_vault.sku_name
}

output "key_vault_enabled_for_template_deployment" {
  description = "value of key vault enabled_for_template_deployment"
  value       = azurerm_key_vault.key_vault.enabled_for_template_deployment
}

output "key_vault_enabled_for_disk_encryption" {
  description = "value of key vault enabled_for_disk_encryption"
  value       = azurerm_key_vault.key_vault.enabled_for_disk_encryption
}

output "key_vault_enable_rbac_authorization" {
  description = "value of key vault enable_rbac_authorization"
  value       = azurerm_key_vault.key_vault.enable_rbac_authorization
}
output "key_vault_enabled_for_deployment" {
  description = "value of key vault enabled_for_deployment"
  value       = azurerm_key_vault.key_vault.enabled_for_deployment
}

output "key_vault_public_network_access_enabled" {
  description = "value of key vault public_network_access_enabled"
  value       = azurerm_key_vault.key_vault.public_network_access_enabled
}

output "key_vault_id" {
  description = "Key Vault ID."
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault" {
  description = "key vault created."
  value       = azurerm_key_vault.key_vault
}