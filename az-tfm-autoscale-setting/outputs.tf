output "autoscale_setting_id" {
  description = "The ID of the autoscale setting."
  value       = azurerm_monitor_autoscale_setting.autoscale.id
}

output "autoscale_setting_name" {
  description = "Name of the autoscale setting."
  value       = azurerm_monitor_autoscale_setting.autoscale.name
}

output "autoscale_setting_target_resource_id" {
  description = "Target resource id of the autoscale setting."
  value       = azurerm_monitor_autoscale_setting.autoscale.target_resource_id
}