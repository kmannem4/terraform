output "resource_id" {
  description = "Log Analytics Resource ID"
  value       = azurerm_log_analytics_workspace.logs.id
}

output "workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.logs.workspace_id
}
