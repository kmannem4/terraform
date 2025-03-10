#---------------------------------
# Local declarations
#---------------------------------

// locals {
//   resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
//   location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
// }

#data "azurerm_log_analytics_workspace" "logws" {
#  count               = var.log_analytics_workspace_name != null ? 1 : 0
#  name                = var.log_analytics_workspace_name
#  resource_group_name = local.resource_group_name
#}

#-------------------------------------------------
# App Service Plan Creation - Default is "true"
#-------------------------------------------------

resource "azurerm_service_plan" "asp" {
  count                        = var.create_app_service_plan ? 1 : 0
  name                         = var.app_service_plan_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  os_type                      = var.os_type
  sku_name                     = var.sku_name
  zone_balancing_enabled       = var.zone_balancing_enabled
  worker_count                 = var.sku_name == "Y1" ? null : var.worker_count
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  app_service_environment_id   = var.app_service_environment_id
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  #tags                         = merge({ "ResourceName" = format("%s", var.app_service_plan_name) }, var.tags, )
  tags = var.tags
}

#---------------------------------------------------------------
# azurerm monitoring diagnostics for App Service Plan
#---------------------------------------------------------------

# resource "azurerm_monitor_diagnostic_setting" "asp-diag" {
#   depends_on                 = [azurerm_service_plan.asp]
#   count                      = var.log_analytics_workspace_id != null && var.create_app_service_plan ? 1 : 0
#   name                       = lower("asp-${var.app_service_plan_name}-diag")
#   target_resource_id         = azurerm_service_plan.asp[count.index].id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }
# Module to create a diagnostic setting
module "diagnostic" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [azurerm_service_plan.asp]                                                                                         # The diagnostic setting depends on the resource group
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-diagnostic-setting?ref=v1.0.0" # Source for the diagnostic setting module
  count                          = var.log_analytics_workspace_id != null && var.create_app_service_plan ? 1 : 0
  diag_name                      = lower("asp-${var.app_service_plan_name}-diag") # Name of the diagnostic setting
  resource_id                    = azurerm_service_plan.asp[count.index].id       # Resource ID to monitor
  log_analytics_workspace_id     = var.log_analytics_workspace_id                 # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                                    # Type of Log Analytics destination
  logs_destinations_ids = [
    var.log_analytics_workspace_id # Log Analytics workspace ID
  ]
}