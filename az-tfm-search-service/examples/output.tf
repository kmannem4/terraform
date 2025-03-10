# SEARCH SERVICE OUTPUT VALUE
output "search_service_id" {
  value = module.search_service.search_service_id
}

output "search_service_name" {
  value = module.search_service.search_service_name
}

output "search_service_hosting_mode" {
  value = module.search_service.search_service_hosting_mode
}

output "search_service_sku" {
  value = module.search_service.search_service_sku
}

output "search_service_replica_count" {
  value = module.search_service.search_service_replica_count
}

output "search_service_partition_count" {
  value = module.search_service.search_service_partition_count
}

output "search_service_public_network_access_enabled" {
  value = module.search_service.search_service_public_network_access_enabled
}

output "search_service_authentication_failure_mode" {
  value = module.search_service.search_service_authentication_failure_mode
}

output "search_service_customer_managed_key_enforcement_enabled" {
  value = module.search_service.search_service_customer_managed_key_enforcement_enabled
}

output "search_service_local_authentication_enabled" {
  value = module.search_service.search_service_local_authentication_enabled
}

output "search_service_identity" {
  value = module.search_service.search_service_identity
}
