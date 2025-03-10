#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = lower(var.resource_group_name)
}

resource "azurerm_resource_group" "rg" { # TODO - Refer resource group module to make it resource & pattern module
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = var.tags
}

#---------------------------------------------------------
# Manage User Assigned Identity.
#----------------------------------------------------------

resource "azurerm_user_assigned_identity" "mi" {
  location            = var.location
  name                = var.user_assigned_identity_name
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rgrp[0].name
  tags                = var.tags
}