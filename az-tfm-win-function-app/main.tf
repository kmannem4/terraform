locals {
  is_kv_access_policy_required                 = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_kv_access_policy_required", false) == true }
  is_network_config_required                   = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_network_config_required", false) == true }
  is_virtual_network_swift_connection_required = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_virtual_network_swift_connection_required", false) == true }
  is_log_analytics_workspace_id_required       = { for k, v in var.function_app_name_vars : k => v if lookup(v, "is_log_analytics_workspace_id_required", false) == true }
}
#---------------------------------------------------------------
# Create Windows Function App
#---------------------------------------------------------------

resource "azurerm_windows_function_app" "function_app" {
  for_each                   = var.function_app_name_vars
  name                       = each.value.function_app_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  storage_account_name       = data.azurerm_storage_account.storage_account[each.key].name
  storage_account_access_key = data.azurerm_storage_account.storage_account[each.key].primary_access_key
  service_plan_id            = data.azurerm_service_plan.app-service-plan[each.key].id
  https_only                 = each.value.https_only
  app_settings               = each.value.app_settings
  site_config {
    use_32_bit_worker   = false
    ftps_state          = each.value.ftps_state
    minimum_tls_version = each.value.minimum_tls_version
    dynamic "ip_restriction" {
      for_each = each.value.ip_restrictions
      content {
        ip_address  = ip_restriction.value.ipAddress
        action      = ip_restriction.value.action
        service_tag = ip_restriction.value.service_tag
        priority    = ip_restriction.value.priority
        name        = ip_restriction.value.name
        description = ip_restriction.value.description
      }
    }
  }
  virtual_network_subnet_id = each.value.is_virtual_network_swift_connection_required ? null : each.value.is_network_config_required ? data.azurerm_subnet.subnet[each.key].id : null
  dynamic "identity" {
    for_each = each.value.function_app_identity != null ? [1] : []
    content {
      type = each.value.function_app_identity.function_app_identity_type
    }
  }
  tags = var.tags
}

#---------------------------------------------------------------
# Vnet Integration for Windows Function App
#---------------------------------------------------------------

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  for_each       = local.is_virtual_network_swift_connection_required
  depends_on     = [azurerm_windows_function_app.function_app]
  app_service_id = azurerm_windows_function_app.function_app[each.key].id
  subnet_id      = data.azurerm_subnet.subnet[each.key].id
}

#---------------------------------------------------------------
# Key Vault Secret Access Permission for Windows Function App
#---------------------------------------------------------------

resource "azurerm_key_vault_access_policy" "kv_access_policies" {
  for_each           = local.is_kv_access_policy_required
  depends_on         = [azurerm_windows_function_app.function_app]
  key_vault_id       = data.azurerm_key_vault.key_vault[each.key].id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_windows_function_app.function_app[each.key].identity[0].principal_id
  secret_permissions = each.value.secret_permissions
}

#-------------------------------------------------
# Module to create a diagnostic setting
module "diagnostic" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  for_each                       = local.is_log_analytics_workspace_id_required
  depends_on                     = [azurerm_windows_function_app.function_app]                                                                        # The diagnostic setting depends on the resource group
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-diagnostic-setting?ref=v1.0.0" # Source for the diagnostic setting module
  diag_name                      = lower("webapp-${azurerm_windows_function_app.function_app[each.key].name}-diag")                                   # Name of the diagnostic setting
  resource_id                    = azurerm_windows_function_app.function_app[each.key].id                                                             # Resource ID to monitor
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id != null ? each.value.log_analytics_workspace_id : null                       # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                                                                                                        # Type of Log Analytics destination
  # Metrics to be collected
  logs_destinations_ids = [
    each.value.log_analytics_workspace_id != null ? each.value.log_analytics_workspace_id : null # Log Analytics workspace ID
  ]
}