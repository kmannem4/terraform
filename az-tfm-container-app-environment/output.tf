# Export the ID of the Container App Environment
output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value = {
    for key, value in azurerm_container_app_environment.main :
    key => value.id
  }
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment"
  value = {
    for key, value in azurerm_container_app_environment.main :
    key => value.name
  }
}
