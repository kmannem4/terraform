output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = azurerm_storage_account.storeacc.name
}

output "resource_group_id" {
  description = "The id of the resource group in which resources are created"
  value       = azurerm_storage_account.storeacc.id
}

output "resource_group_location" {
  description = "Azure location of the created Service Plan"
  value       = azurerm_storage_account.storeacc.location
}

output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storeacc.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storeacc.name
}

output "access_tier" {
  description = "The name of the access tier."
  value       = azurerm_storage_account.storeacc.access_tier
}

output "location" {
  description = "The name of the location."
  value       = azurerm_storage_account.storeacc.location
}

output "account_kind" {
  description = "The name of the account_kind."
  value       = azurerm_storage_account.storeacc.account_kind
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.storeacc.primary_location
}

output "storage_account_primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.storeacc.primary_blob_endpoint
}

output "storage_account_primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.storeacc.primary_web_endpoint
}

output "storage_account_primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location."
  value       = azurerm_storage_account.storeacc.primary_web_host
}

output "storage_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.storeacc.primary_connection_string
  sensitive   = true
}

output "storage_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.storeacc.primary_access_key
  sensitive   = true
}

output "storage_secondary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.storeacc.secondary_access_key
  sensitive   = true
}

output "containers" {
  description = "Map of containers."
  value       = { for c in azurerm_storage_container.container : c.name => c.id }
}

output "file_shares" {
  description = "Map of Storage SMB file shares."
  value       = { for f in azurerm_storage_share.fileshare : f.name => f.id }
}

output "tables" {
  description = "Map of Storage SMB file shares."
  value       = { for t in azurerm_storage_table.tables : t.name => t.id }
}

output "queues" {
  description = "Map of Storage SMB file shares."
  value       = { for q in azurerm_storage_queue.queues : q.name => q.id }
}
