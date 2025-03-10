#-------------------------------------------------
# Data Blocks
#-------------------------------------------------

data "azurerm_client_config" "current" {}

data "azurerm_application_insights" "application_insights" {
  for_each            = local.is_appinsights_instrumentation_key_required
  name                = each.value.web_app_application_insights_name
  resource_group_name = each.value.web_app_application_insights_resource_group_name
}

data "azurerm_subnet" "subnet" {
  for_each             = local.is_network_config_required
  name                 = each.value.network_config_subnet_name
  virtual_network_name = each.value.network_config_virtual_network_name
  resource_group_name  = each.value.network_config_virtual_network_resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  for_each            = local.is_kv_access_policy_required
  name                = each.value.kv_name
  resource_group_name = each.value.kv_resource_group_name
}

data "azurerm_windows_web_app" "win_web_app" {
  for_each            = var.web_slot_vars
  name                = each.value.web_app_name
  resource_group_name = var.resource_group_name
}