# SEARCH SERVICE OUTPUT VALUE
output "search_service_id" {
  value = azurerm_search_service.search_service.id
}

output "search_service_name" {
  value = azurerm_search_service.search_service.name
}

output "search_service_hosting_mode" {
  value = azurerm_search_service.search_service.hosting_mode
}

output "search_service_sku" {
  value = azurerm_search_service.search_service.sku
}

output "search_service_replica_count" {
  value = azurerm_search_service.search_service.replica_count
}

output "search_service_partition_count" {
  value = azurerm_search_service.search_service.partition_count
}

output "search_service_public_network_access_enabled" {
  value = azurerm_search_service.search_service.public_network_access_enabled
}

output "search_service_authentication_failure_mode" {
  value = azurerm_search_service.search_service.authentication_failure_mode
}

output "search_service_customer_managed_key_enforcement_enabled" {
  value = azurerm_search_service.search_service.customer_managed_key_enforcement_enabled
}

output "search_service_local_authentication_enabled" {
  value = azurerm_search_service.search_service.local_authentication_enabled
}

output "search_service_identity" {
  value = azurerm_search_service.search_service.identity[0].type
}
