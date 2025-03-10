# Retrieve diagnostic categories for the target resource
data "azurerm_monitor_diagnostic_categories" "categories" {
  # Create the resource only if diagnostic settings are enabled
  count = local.enabled ? 1 : 0

  # Resource ID of the target resource
  resource_id = var.resource_id
}

# Create a diagnostic setting for the target resource
resource "azurerm_monitor_diagnostic_setting" "diagnostic" {
  # Create the resource only if diagnostic settings are enabled
  count = local.enabled ? 1 : 0

  # Name of the diagnostic setting
  name = var.diag_name

  # Resource ID of the target resource
  target_resource_id = var.resource_id

  # Commented out options for other log destinations
  # storage_account_id             = local.storage_id

  # Set the Log Analytics Workspace ID if provided
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Set the Log Analytics destination type if provided
  log_analytics_destination_type = local.log_analytics_destination_type

  # Commented out options for Event Hub destination
  # eventhub_authorization_rule_id = local.eventhub_authorization_rule_id
  # eventhub_name                  = local.eventhub_name

  # Dynamically configure enabled logs based on the log_categories local
  dynamic "enabled_log" {
    for_each = local.log_categories

    content {
      category = enabled_log.value
    }
  }

  # Dynamically configure metrics based on the metrics local
  dynamic "metric" {
    for_each = local.metrics

    content {
      category = metric.key
      enabled  = metric.value.enabled
    }
  }

  # Ignore changes to log_analytics_destination_type during updates
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
