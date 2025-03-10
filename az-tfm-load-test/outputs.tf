output "id" {
  description = "The ID of the Load Test."
  value       = azurerm_load_test.load_test.id
}

output "data_plane_uri" {
  description = "Resource data plane URI."
  value       = azurerm_load_test.load_test.data_plane_uri
}

output "description" {
  description = "The description of the Load Test."
  value       = azurerm_load_test.load_test.description
}

output "test_name" {
  description = "The name of the Test."
  value       = azurerm_load_test.load_test.name
}

output "test_location" {
  description = "The location of the Test."
  value       = azurerm_load_test.load_test.location
}

output "test_encryption" {
  description = "The encryption of the Test."
  value       = azurerm_load_test.load_test.encryption
}

