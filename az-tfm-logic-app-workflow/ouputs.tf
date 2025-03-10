output "logic_app_workflow_name" {
  description = "value of logic_app_workflow_name"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.name }
}
output "logic_app_workflow_id" {
  description = "value of logic_app_workflow_id"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.id }
}

output "logic_app_endpoint" {
  description = "value of logic_app_endpoint"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.access_endpoint }
}
output "logic_app_identity" {
  description = "The principal ID of the assigned identity for the Logic App Workflow."
  value = {
    for k, v in azurerm_logic_app_workflow.main :
    k => length(v.identity) > 0 ? v.identity[0].principal_id : null
  }
}

output "connector_endpoint_ip_addresses" {
  description = "value of connector_endpoint_ip_addresses"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.connector_endpoint_ip_addresses }
}
output "connector_outbound_ip_addresses" {
  description = "value of connector_outbound_ip_addresses"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.connector_outbound_ip_addresses }
}

output "workflow_endpoint_ip_addresses" {
  description = "value of workflow_endpoint_ip_addresses"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.workflow_endpoint_ip_addresses }
}

output "workflow_outbound_ip_addresses" {
  description = "value of workflow_outbound_ip_addresses"
  value       = { for k, v in azurerm_logic_app_workflow.main : k => v.workflow_outbound_ip_addresses }
}