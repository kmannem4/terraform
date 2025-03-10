variable "location" {
  description = "Azure location."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID."
  default     = null
  type        = string
}

variable "infrastructure_resource_group_name" {
  description = "Infrastructure Resource Group Name."
  default     = null
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "Infrastructure Subnet ID."
  default     = null
  type        = string
}