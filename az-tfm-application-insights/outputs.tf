# Application insights ID OUTPUT VALUE
output "app_insights_id" {
  value = azurerm_application_insights.application_insights.id
}

output "instrumentation_key" {
  value = azurerm_application_insights.application_insights.instrumentation_key
  sensitive = true
}

output "application_insight_name" {
  value = azurerm_application_insights.application_insights.name
}

output "location" {
  value = azurerm_application_insights.application_insights.location
}

output "local_authentication_disabled" {
  value = azurerm_application_insights.application_insights.local_authentication_disabled
}

output "application_type" {
  value = azurerm_application_insights.application_insights.application_type
}

output "retention_in_days" {
  value = azurerm_application_insights.application_insights.retention_in_days
}