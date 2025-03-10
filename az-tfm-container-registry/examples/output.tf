output "container_registry_id" {
  description = "ID of the created container registry ID"
  value       = module.container_registry.container_registry_id
}

output "container_registry_name" {
  description = "Name of the created container registry"
  value       = module.container_registry.container_registry_name
}

output "location" {
  description = "Azure location of the created container registry"
  value       = module.container_registry.location
}

output "sku_name" {
  description = "The SKU for the container registry"
  value       = module.container_registry.sku_name
}

output "admin_enabled" {
  description = "The admin enabled for the container registry"
  value       = module.container_registry.admin_enabled
}

output "public_network_access_enabled" {
  description = "The public network access enabled for the container registry"
  value       = module.container_registry.public_network_access_enabled
}

output "zone_redundancy_enabled" {
  description = "The zone redundancy enabled for the container registry"
  value       = module.container_registry.zone_redundancy_enabled
}