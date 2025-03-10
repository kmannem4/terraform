// output "service_plan_id" {
//   description = "ID of the created Service Plan"
//   value       = length(azurerm_service_plan.asp) > 0 ? azurerm_service_plan.asp[0].id : null
// }

// output "service_plan_name" {
//   description = "Name of the created Service Plan"
//   value       = length(azurerm_service_plan.asp) > 0 ? azurerm_service_plan.asp[0].name : null
// }

// output "service_plan_location" {
//   description = "Azure location of the created Service Plan"
//   value       = length(azurerm_service_plan.asp) > 0 ? azurerm_service_plan.asp[0].location : null
// }

output "service_plan_id" {
  description = "ID of the created Service Plan"
  value       = azurerm_service_plan.asp[0].id
}

output "service_plan_name" {
  description = "Name of the created Service Plan"
  value       = azurerm_service_plan.asp[0].name
}

output "service_plan_location" {
  description = "Azure location of the created Service Plan"
  value       = azurerm_service_plan.asp[0].location
}

output "os_type" {
  description = "The O/S type for the App Services to be hosted in this plan"
  value       = azurerm_service_plan.asp[0].os_type
}

output "sku_name" {
  description = "The SKU for the plan"
  value       = azurerm_service_plan.asp[0].sku_name
}