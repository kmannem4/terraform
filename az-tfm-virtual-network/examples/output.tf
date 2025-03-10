output "virtual_network_id" {
  value       = module.virtual_network.virtual_network_id
  description = "The virtual NetworkConfiguration ID."
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = module.virtual_network.resource_group_location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.virtual_network.virtual_network_name
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = module.virtual_network.virtual_network_address_space
}

output "subnet_ids" {
  description = "List of IDs of subnets"
  value       = module.virtual_network.subnet_ids
}

output "subnet_address_prefixes" {
  description = "List of address prefix for subnets"
  value       = module.virtual_network.subnet_address_prefixes
}

output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = module.virtual_network.network_security_group_ids
}

output "ddos_protection_plan" {
  description = "Ddos protection plan details"
  value       = module.virtual_network.ddos_protection_plan
}

output "network_watcher_id" {
  description = "ID of Network Watcher"
  value       = module.virtual_network.network_watcher_id
}

output "vnet" {
  description = "Vnet"
  value       = module.virtual_network.vnet
}

output "network_security_group_names" {
  value       = module.virtual_network.network_security_group_names
  description = "network_security_group_names"
}

output "xx_module_virtual_network_dns_servers" {
  value       = module.virtual_network.dns_servers
  description = "subnet_ids"
}
output "xy_module_virtual_network_dns_servers" {
  value       = tolist(var.dns_servers)
  description = "subnet_ids"
}

output "xz_module_virtual_network_dns_servers" {
  value       = module.virtual_network.dns_servers == (tolist(var.dns_servers))
  description = "subnet_ids"
}

