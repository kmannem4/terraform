resource "azurerm_container_registry" "acr" {
  #checkov:skip=CKV_AZURE_164: skip
  #checkov:skip=CKV_AZURE_167: skip
  #checkov:skip=CKV_AZURE_165: skip
  #checkov:skip=CKV_AZURE_166: skip
  #checkov:skip=CKV_AZURE_163: skip
  #checkov:skip=CKV_AZURE_138: skip
  #checkov:skip=CKV_AZURE_233: skip
  #checkov:skip=CKV_AZURE_237: skip
  name                          = var.container_registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku_name
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  georeplications {
    location                = var.georeplications_location
    zone_redundancy_enabled = var.georeplications_zone_redundancy_enabled
  }
  network_rule_set {
    default_action = var.default_action
    ip_rule {
      action   = var.action
      ip_range = var.ip_range
    }
  }
  tags = var.tags
}