# SEARCH SERVICE RESOURCE BLOCK
resource "azurerm_search_service" "search_service" {
  #checkov:skip=CKV_AZURE_210: "Ensure Azure Cognitive Search service allowed IPS does not give public Access"
  #checkov:skip=CKV_AZURE_124: "Ensure that Azure Cognitive Search disables public network access"
  name                                     = var.search_service_name
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  sku                                      = var.search_service_sku
  replica_count                            = var.search_service_replica_count
  partition_count                          = var.search_service_partition_count
  public_network_access_enabled            = var.search_service_public_network_access_enabled
  allowed_ips                              = var.search_service_allowed_ips
  authentication_failure_mode              = var.search_service_authentication_failure_mode
  customer_managed_key_enforcement_enabled = var.search_service_customer_managed_key_enforcement_enabled
  local_authentication_enabled             = var.search_service_local_authentication_enabled
  hosting_mode                             = var.search_service_hosting_mode
  tags                                     = var.tags

  dynamic "identity" {
    for_each = var.search_service_identity != null ? [1] : []
    content {
      type = var.search_service_identity
    }
  }
}