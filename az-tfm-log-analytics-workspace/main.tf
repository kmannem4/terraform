#---------------------------------------------------------
# Resource Group selection - Default is "true"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  name = var.resource_group_name
}

// Creates Log Analytics Workspace
// Optional
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.name}-logs"
  location            = data.azurerm_resource_group.rgrp.location
  resource_group_name = data.azurerm_resource_group.rgrp.name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}


// Creates Security Center Workspace
// Optional
resource "azurerm_security_center_workspace" "logs" {
  count        = length(var.security_center_subscription)
  scope        = "/subscriptions/${element(var.security_center_subscription, count.index)}"
  workspace_id = azurerm_log_analytics_workspace.logs.id
}


// Creates Log Analytics Solution
// Optional
resource "azurerm_log_analytics_solution" "logs" {
  count                 = length(var.solutions)
  solution_name         = var.solutions[count.index].solution_name
  location              = data.azurerm_resource_group.rgrp.location
  resource_group_name   = data.azurerm_resource_group.rgrp.name
  workspace_resource_id = azurerm_log_analytics_workspace.logs.id
  workspace_name        = azurerm_log_analytics_workspace.logs.name

  plan {
    publisher = var.solutions[count.index].publisher
    product   = var.solutions[count.index].product
  }

  tags = var.tags
}
