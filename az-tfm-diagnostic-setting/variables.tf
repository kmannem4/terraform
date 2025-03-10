# Resource ID of the resource to enable diagnostic settings on
variable "resource_id" {
  type        = string
  description = "The ID of the resource on which activate the diagnostic settings."
}

# List of log categories to collect
variable "log_categories" {
  type        = list(string)
  default     = null
  description = "List of log categories. Defaults to all available."
}


# List of log categories to exclude
variable "excluded_log_categories" {
  type        = list(string)
  default     = []
  description = "List of log categories to exclude."
}

# List of metric categories to collect
variable "metric_categories" {
  type        = list(string)
  default     = null
  description = "List of metric categories. Defaults to all available."
}

# List of destination resource IDs for logs
variable "logs_destinations_ids" {
  type        = list(string)
  nullable    = false
  description = <<EOD
List of destination resources IDs for logs diagnostic destination.
Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.
If you want to use Azure EventHub as destination, you must provide a formatted string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character.  
EOD
}

# Type of Log Analytics destination
variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "When set to 'Dedicated' logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table."
}

# Resource ID of the Log Analytics Workspace
variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Resource ID of LAW."
}

# Name of the diagnostic setting
variable "diag_name" {
  type        = string
  description = "Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created."
}