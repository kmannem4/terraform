
output "container_app_name" {
  value       = { for key, container_app in azurerm_container_app.container_app : key => container_app.name }
  description = "value of container app name"
}

output "container_app_id" {
  value       = { for key, container_app in azurerm_container_app.container_app : key => container_app.id }
  description = "value of container app id"
}