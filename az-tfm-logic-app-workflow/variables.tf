variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Location of the resource group."
  type        = string
}

variable "logic_app_vars" {
  description = "A mapping of logic app variables to assign to the resource"
  type = map(object({
    name = string
    identity = optional(object({
      identity_ids = optional(list(string))
    }))
    integration_service_environment_id = optional(string)
    logic_app_integration_account_id   = optional(string)
    enabled                            = optional(bool)
    workflow_parameters                = optional(map(any))
    parameters                         = optional(map(any))
    workflow_schema                    = optional(string)
    workflow_version                   = optional(string)
  }))
}
