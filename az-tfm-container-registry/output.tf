output "container_registry_id" {
  description = "ID of the created container registry ID"
  value       = azurerm_container_registry.acr.id
}

output "container_registry_name" {
  description = "Name of the created Service container registry"
  value       = azurerm_container_registry.acr.name
}

output "location" {
  description = "Azure location of the created Service container registry"
  value       = azurerm_container_registry.acr.location
}

output "sku_name" {
  description = "The SKU for the container registry"
  value       = azurerm_container_registry.acr.sku
}

output "admin_enabled" {
  description = "The admin enabled for the container registry"
  value       = azurerm_container_registry.acr.admin_enabled
}

output "public_network_access_enabled" {
  description = "The public network access enabled for the container registry"
  value       = azurerm_container_registry.acr.public_network_access_enabled
}

output "zone_redundancy_enabled" {
  description = "The zone redundancy enabled for the container registry"
  value       = azurerm_container_registry.acr.zone_redundancy_enabled
}