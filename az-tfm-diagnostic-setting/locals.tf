locals {
  # Determine if diagnostic settings are enabled based on the presence of log destination IDs
  enabled = length(var.logs_destinations_ids) > 0

  # Define log categories to be collected
  # If log_categories variable is not null, use it, otherwise use log_category_types from data source
  # Exclude log categories specified in excluded_log_categories variable
  log_categories = [
    for log in
    (
      var.log_categories != null ?
      var.log_categories :
      try(data.azurerm_monitor_diagnostic_categories.categories[0].log_category_types, [])
    ) : log if !contains(var.excluded_log_categories, log)
  ]

  # Define metric categories to be collected
  # If metric_categories variable is not null, use it, otherwise use metrics from data source
  metric_categories = (
    var.metric_categories != null ?
    var.metric_categories :

    try(data.azurerm_monitor_diagnostic_categories.categories[0].metrics, [])
  )

  # Create a map of metrics with their enabled status
  # A metric is enabled if it is present in the metric_categories list
  metrics = {
    for metric in try(data.azurerm_monitor_diagnostic_categories.categories[0].metrics, []) : metric => {
      enabled = contains(local.metric_categories, metric)
    }
  }

  # Commented out code for extracting IDs from logs_destinations_ids
  # storage_id       = coalescelist([for r in var.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.storage")], [null])[0]
  # log_analytics_id = coalescelist([for r in var.logs_destinations_ids : r if contains(split("/", lower(r)), "microsoft.operationalinsights")], [null])[0]

  # eventhub_authorization_rule_id = coalescelist([for r in var.logs_destinations_ids : split("|", r)[0] if contains(split("/",lower(r)), "microsoft.eventhub")], [null])[0]
  # eventhub_name                  = coalescelist([for r in var.logs_destinations_ids : try(split("|", r)[1], null) if contains(split("/", lower(r)), "microsoft.eventhub")], [null])[0]

  # Determine the log analytics destination type based on the presence of log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_workspace_id != null ? var.log_analytics_destination_type : null
}
