variable "location" {
  description = "Azure location for SignalR."
  type        = string
}

variable "sku" {
  description = "Signalr SKU"
  type = object({
    name     = string,
    capacity = number
  })
}

variable "allowed_origins" {
  description = "A List of origins which should be able to make cross-origin calls."
  type        = list(string)
  default     = []
}

variable "connectivity_logs_enabled" {
  description = "Specifies if Connectivity Logs are enabled or not"
  type        = bool
  default     = true
}

variable "messaging_logs_enabled" {
  description = "Specifies if Messaging Logs are enabled or not"
  type        = bool
  default     = true
}

variable "live_trace_enabled" {
  description = "Specifies if Live Trace is enabled or not"
  type        = bool
  default     = true
}

variable "http_request_logs_enabled" {
  description = "Specifies if Http Request Logs are enabled or not."
  type        = bool
  default     = true
}

variable "service_mode" {
  description = "Specifies the service mode"
  type        = string
  default     = "Default"
}

variable "public_network_access_enabled" {
  description = "Specifies if the public access is enabled or not."
  type        = bool
  default     = false
}

variable "network_acl_default_action" {
  description = "The default action to control the network access when no other rule matches. Possible values are Allow and Deny."
  type        = string
  default     = "Deny"
}

variable "public_network_allowed_request_types" {
  type        = list(string)
  default     = ["ServerConnection","ClientConnection","RESTAPI","Trace"]
  description = "The allowed request types for the public network. Possible values are ClientConnection, ServerConnection, RESTAPI and Trace. When network_acl_default_action is Allow, public_network_allowed_request_types cannot be set."
}

variable "public_network_denied_request_types" {
  type        = list(string)
  default     = ["ServerConnection","ClientConnection","RESTAPI","Trace"]
  description = "The denied request types for the public network. Possible values are ClientConnection, ServerConnection, RESTAPI and Trace. When network_acl_default_action is Deny, public_network_denied_request_types cannot be set."
}

variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}