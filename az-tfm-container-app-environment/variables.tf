variable "location" {
  description = "Azure location."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
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

variable "container_app_environment_vars" {
  description = "Map of Container App Environment variables"
  type = map(object({
    name                                        = string
    mutual_tls_enabled                          = optional(bool)
    zone_redundancy_enabled                     = optional(bool)
    internal_load_balancer_enabled              = optional(bool)
    dapr_application_insights_connection_string = optional(string)
    workload_profile = optional(list(object({
      name                  = string
      workload_profile_type = string
      minimum_count         = number
      maximum_count         = number
    })))
  }))
}
