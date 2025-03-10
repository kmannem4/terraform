resource "azurerm_load_test" "load_test" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name

  # Conditionally include description if not empty
  description = var.description != "" ? var.description : null

  dynamic "identity" {
   for_each = var.identity.identity_ids != [] ? [1] : []
   content {
     type         = var.identity.type
     identity_ids = var.identity.identity_ids
   }
  }

  dynamic "encryption" {
   for_each = var.customer_managed_key_url != "" ? [1] : []
   content {
      identity {
        type = var.identity.type
        identity_id = var.identity.identity_ids
        // dynamic "identity_id" {
        //   for_each = var.identity.type == "UserAssigned" ? [1] : []
        //   content  {
        //     identity_id = var.identity.identity_ids
        //   }
        // }
      }

      key_url = var.customer_managed_key_url
    }
  }

  tags = var.tags
}