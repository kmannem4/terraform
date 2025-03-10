# Output the ID of the created diagnostic setting
output "diagnostic_settings_id" {
  # Description of the output
  description = "ID of the Diagnostic Settings."
  # Get the ID of the diagnostic setting, or return null if it doesn't exist
  value = try(azurerm_monitor_diagnostic_setting.diagnostic[0].id, null)
}

output "target_resource_id" {
  description = "resource id of the target resource"
  value = try(azurerm_monitor_diagnostic_setting.diagnostic[0].target_resource_id, null)
}