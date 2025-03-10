output "api_management_name" {
  value       = azurerm_api_management.apim.name
  description = "The Name of the API Management resource"
}
output "api_management_id" {
  value       = resource.azurerm_api_management.apim.id
  description = "The ID of the API Management resource"
}
output "additional_location" {
  value       = azurerm_api_management.apim.additional_location
  description = "A `additional_location` block as defined below"
}
output "gateway_url" {
  value       = azurerm_api_management.apim.gateway_url
  description = "The URL for the API Management Service's Gateway."
}
output "gateway_regional_url" {
  value       = azurerm_api_management.apim.gateway_regional_url
  description = "The URL for the API Management Service's Gateway."
}
output "portal_url" {
  value       = azurerm_api_management.apim.portal_url
  description = "The URL for the API Management Service's Portal."
}
output "management_api_url" {
  value       = azurerm_api_management.apim.management_api_url
  description = "The URL for the API Management Service's Management API."
}
output "identity" {
  value       = azurerm_api_management.apim.identity
  description = "An `identity` block as defined below"
}
output "hostname_configuration" {
  value       = azurerm_api_management.apim.hostname_configuration
  description = "A `hostname_configuration` block as defined below"
}
output "developer_portal" {
  value       = azurerm_api_management.apim.hostname_configuration[0].developer_portal
  description = "A `developer_portal` block as defined below"
}
output "public_ip_addresses" {
  value       = azurerm_api_management.apim.public_ip_addresses
  description = "A list of public IP addresses assigned to this API Management service. Each address is a string"
}
output "private_ip_addresses" {
  value       = azurerm_api_management.apim.private_ip_addresses
  description = "A list of private IP addresses assigned to this API Management service. Each address is a string"
}
output "scm_url" {
  value       = azurerm_api_management.apim.scm_url
  description = "The URL for the API Management Service's SCM (Git-based version control)"
}
output "tenant_access" {
  value       = azurerm_api_management.apim.tenant_access
  description = "A `tenant_access` block as defined below"
}
output "certificate" {
  value       = azurerm_api_management.apim.certificate
  description = "A `certificate` block as defined below"
}
output "proxy" {
  value       = azurerm_api_management.apim.hostname_configuration[0].proxy
  description = "A `proxy` block as defined below"
}