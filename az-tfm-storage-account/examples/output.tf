output "storage_account_id" {
  description = "The ID of the storage account."
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = module.storage.storage_account_name
}

output "location" {
  description = "The name of the location."
  value       = module.storage.location
}

output "account_kind" {
  description = "The name of the account_kind."
  value       = module.storage.account_kind
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = module.storage.storage_account_primary_location
}

output "containers" {
  description = "Map of containers."
  value       = module.storage.containers #{ for c in module.storage.containers : c.name => c.id }
}

