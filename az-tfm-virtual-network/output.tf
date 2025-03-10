output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = azurerm_virtual_network.vnet.location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.name, [""]), 0)
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.id, [""]), 0)
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = element(coalescelist(azurerm_virtual_network.vnet.*.address_space, [""]), 0)
}

output "subnet_ids" {
  description = "List of IDs of subnets"
  value       = flatten(concat([for s in azurerm_subnet.snet : s.id], [var.gateway_subnet_address_prefix != null ? azurerm_subnet.gw_snet.0.id : null], [var.firewall_subnet_address_prefix != null ? azurerm_subnet.fw-snet.0.id : null]))
}

output "subnet_names" {
  description = "List of Names of subnets"
  value       = flatten(concat([for s in azurerm_subnet.snet : s.name], [var.gateway_subnet_address_prefix != null ? azurerm_subnet.gw_snet.0.name : null], [var.firewall_subnet_address_prefix != null ? azurerm_subnet.fw-snet.0.name : null]))
}

output "subnet_address_prefixes" {
  description = "List of address prefix for subnets"
  value       = flatten(concat([for s in azurerm_subnet.snet : s.address_prefixes], [var.gateway_subnet_address_prefix != null ? azurerm_subnet.gw_snet.0.address_prefixes : null], [var.firewall_subnet_address_prefix != null ? azurerm_subnet.fw-snet.0.address_prefixes : null]))
}

output "network_security_group_ids" {
  description = "List of Network security group ids"
  value       = [for n in azurerm_network_security_group.nsg : n.id]
}

output "network_security_group_names" {
  description = "List of Network security group names"
  value       = { for k, v in azurerm_network_security_group.nsg : k => { value = v.name } }
}

output "ddos_protection_plan" {
  description = "Ddos protection plan details"
  value       = var.create_ddos_plan ? element(concat(azurerm_network_ddos_protection_plan.ddos.*.id, [""]), 0) : null
}

output "network_watcher_id" {
  description = "ID of Network Watcher"
  value       = var.create_network_watcher != false ? element(concat(azurerm_network_watcher.nwatcher.*.id, [""]), 0) : null
}

output "vnet" {
  description = "Vnet"
  value       = azurerm_virtual_network.vnet
}

output "edge_zone" {
  description = "edge_zone of Vnet"
  value       = azurerm_virtual_network.vnet.edge_zone
}

output "flow_timeout_in_minutes" {
  description = "flow_timeout_in_minutes of Vnet"
  value       = azurerm_virtual_network.vnet.flow_timeout_in_minutes
}

output "dns_servers" {
  description = "dns_servers of Vnet"
  value       = azurerm_virtual_network.vnet.dns_servers
}

output "ddos_plan_name" {
  description = "ddos_plan_name of Vnet"
  value       = var.create_ddos_plan ? azurerm_network_ddos_protection_plan.ddos[0].name : ""
}
