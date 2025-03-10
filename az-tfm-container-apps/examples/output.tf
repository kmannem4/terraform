# Export the ID of the Container App Environment
output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = module.container_app_environment.container_app_environment_id["Test"]
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment"
  value       = module.container_app_environment.container_app_environment_name["Test"]
}

output "container_app_name" {
  value       = module.container_app.container_app_name["Test"]
  description = "value of container app name"
}

output "container_app_id" {
  value       = module.container_app.container_app_id["Test"]
  description = "value of container app id"
}