output "windows_web_app_service" {
  description = "App Services"
  value       = module.web_app_service.windows_web_app_service
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "app_service_plan_name" {
  description = "Name of the Service Plan"
  value       = module.app_service_plan.service_plan_name
}

output "app_service_plan_location" {
  description = "Azure location of the Service Plan"
  value       = module.app_service_plan.service_plan_location
}

output "app_service_plan_os_type" {
  description = "The O/S type for the App Services to be hosted in this plan"
  value       = module.app_service_plan.os_type
}

output "app_service_plan_sku_name" {
  description = "The SKU for the plan"
  value       = module.app_service_plan.sku_name
}
