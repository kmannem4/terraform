# Azurerm Provider configuration
provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

module "user_assigned_identity" {
  source                      = "../"
  create_resource_group       = var.create_resource_group
  resource_group_name         = local.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.user_assigned_identity_name
  tags                        = var.tags
}