

output "data_factory_id" {
  description = "The ID of the Azure Data Factory"
  value       = module.data_factory.data_factory_id
}

output "data_factory_name" {
  description = "The name of the Azure Data Factory"
  value       = module.data_factory.data_factory_outputs.name
}

output "public_network_enabled" {
  description = "value of public_network_enabled in data_factory_config"
  value = module.data_factory.data_factory_outputs.public_network_enabled
}

output "managed_virtual_network_enabled" {
  description = "value of managed_virtual_network_enabled in data_factory_config"
  value = module.data_factory.data_factory_outputs.managed_virtual_network_enabled
  
}