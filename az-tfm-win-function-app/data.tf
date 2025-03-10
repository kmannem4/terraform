data "azurerm_client_config" "current" {}

data "azurerm_service_plan" "app-service-plan" {
  for_each            = var.function_app_name_vars
  name                = each.value.app_service_plan_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_account" "storage_account" {
  for_each            = var.function_app_name_vars
  name                = each.value.storage_account_name
  resource_group_name = each.value.storage_resource_group_name
}

data "azurerm_subnet" "subnet" {
  for_each             = local.is_network_config_required
  name                 = each.value.vnet_subnet
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.vnet_resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  for_each            = local.is_kv_access_policy_required
  name                = each.value.key_vault
  resource_group_name = each.value.key_vault_resource_group_name
}