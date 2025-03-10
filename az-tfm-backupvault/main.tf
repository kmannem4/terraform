resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
  tags                = var.tags

  dynamic "identity" {
    for_each = var.identity.identity_ids != [] ? [1] : []
    content {
      type = var.identity.type
    }
  }
}
