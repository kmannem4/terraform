variable "location" {
  description = "location off the resource group"
  type        = string
}
variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}
variable "create_resource_group" {
  description = "value to create resource group"
  type        = bool
  default     = false
}
variable "action_group" {
  description = "A map of objects representing action group configurations."
  type = map(object({
    name       = string
    short_name = string
    action     = optional(bool)
    armrole_receivers = optional(list(object({
      name                    = string
      role_id                 = string
      use_common_alert_schema = bool
    })))
    automation_runbook_receiver = optional(list(object({
      name                    = string
      automation_account_id   = string
      runbook_name            = string
      webhook_resource_id     = string
      is_global_runbook       = bool
      service_uri             = optional(string)
      use_common_alert_schema = optional(bool)
    })))
    azure_app_push_receiver = optional(list(object({
      name          = string
      email_address = string
    })))
    azure_function_receiver = optional(list(object({
      name                     = string
      function_app_resource_id = string
      function_name            = string
      http_trigger_url         = string
      use_common_alert_schema  = bool
    })))
    email_receivers = optional(list(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = bool
    })))
    event_hub_receiver = optional(list(object({
      name                    = string
      event_hub_name          = string
      event_hub_namespace     = string
      subscription_id         = optional(string)
      tenant_id               = string
      use_common_alert_schema = bool
    })))
    itsm_receiver = optional(list(object({
      name                 = string
      workspace_id         = string
      connection_id        = string
      ticket_configuration = string
      region               = string
    })))
    location = optional(string)
    logic_app_receiver = optional(list(object({
      name                    = string
      callback_url            = string
      resource_id             = string
      use_common_alert_schema = bool
    })))
    sms_receivers = optional(list(object({
      name         = string
      country_code = number
      phone_number = number
    })))
    voice_receivers = optional(list(object({
      name         = string
      country_code = number
      phone_number = number
    })))
    webhook_receiver = optional(list(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = bool
      aad_auth = object({
        object_id      = string
        identifier_uri = string
        tenant_id      = string
      })
    })))
  }))
}
