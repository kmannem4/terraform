/**
output "secret_value" {
  value     = data.azurerm_key_vault_secret.example.value
  sensitive = true
}
**/

/**output "subnets_info" {
//  value = var.subnets.pvt_subnet.subnet_name
}**/

output "subnet_ids" {
  description = "List of IDs of subnets"
  value       = module.vnet.subnet_ids[0]
}
output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  //value       = [for n in azurerm_network_security_group.nsg : n.id]
  value = module.vnet.network_security_group_ids[1]
}

/**
output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = module.virtual-machine.*.windows_virtual_machine_ids
}
**/