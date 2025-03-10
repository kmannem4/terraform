variable "name" {
  description = "Name of LAW"
}

variable "resource_group_name" {
  description = "Resource Group Name"
  default     = ""
}

variable "sku" {
  description = "Specified the Sku of the Log Analytics Workspace."
  default     = "PerNode"
}

variable "retention_in_days" {
  description = "The workspace data retetion in days. Possible values range between 30 and 730."
  default     = 30
}

variable "security_center_subscription" {
  description = "List of subscriptions this log analytics should collect data for. Does not work on free subscription."
  type        = list(string)
  default     = []
}

variable "solutions" {
  description = "A list of solutions to add to the workspace. Should contain solution_name, publisher and product."
  type        = list(object({ solution_name = string, publisher = string, product = string }))
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {}
}
