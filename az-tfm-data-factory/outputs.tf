output "data_factory_id" {
  description = "The ID of the Azure Data Factory"
  value       = azurerm_data_factory.data_factory.id
}

output "data_factory_name" {
  description = "The name of the Azure Data Factory"
  value       = azurerm_data_factory.data_factory.name
}

output "data_factory_outputs" {
  value = azurerm_data_factory.data_factory
}