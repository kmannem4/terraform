# locals
locals {
  default_tags = {}
  tags         = merge(local.default_tags, var.tags)
}

# Resource Group
resource "azurerm_resource_group" "default" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}
