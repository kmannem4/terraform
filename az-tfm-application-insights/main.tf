resource "azurerm_application_insights" "application_insights" {
  name                          = var.application_insight_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  application_type              = var.application_type
  retention_in_days             = var.retention_in_days
  workspace_id                  = var.workspace_id
  local_authentication_disabled = var.local_authentication_disabled
  tags                          = var.tags
}