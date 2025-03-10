output "service_plan_id" {
  description = "ID of the created Service Plan"
  value       = module.app_service_plan.service_plan_id
}

output "service_plan_name" {
  description = "Name of the created Service Plan"
  value       = module.app_service_plan.service_plan_name
}

output "service_plan_location" {
  description = "Azure location of the created Service Plan"
  value       = module.app_service_plan.service_plan_location
}

output "os_type" {
  description = "The O/S type for the App Services to be hosted in this plan"
  value       = module.app_service_plan.os_type
}

output "sku_name" {
  description = "The SKU for the plan"
  value       = module.app_service_plan.sku_name
}