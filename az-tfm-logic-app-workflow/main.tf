
resource "azurerm_logic_app_workflow" "main" {
  for_each            = var.logic_app_vars
  name                = each.value.name
  tags                = var.tags
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "identity" {
    for_each = each.value.identity == null ? [] : [each.value.identity]
    content {
      type         = identity.value.identity_ids == null ? "SystemAssigned" : "UserAssigned"
      identity_ids = identity.value.identity_ids
    }
  }

  integration_service_environment_id = each.value.integration_service_environment_id
  logic_app_integration_account_id   = each.value.logic_app_integration_account_id
  enabled                            = each.value.enabled
  workflow_parameters                = each.value.workflow_parameters
  parameters                         = each.value.parameters
  workflow_schema                    = each.value.workflow_schema
  workflow_version                   = each.value.workflow_version

}
