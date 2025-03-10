variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where the Application Insights should be created."
  type        = string
  default     = "westus2"
}

variable "application_insight_name" {
  description = "The name of the Application Insights resource."
  type        = string
}

variable "application_type" {
  description = "The type of the Application Insights web or app."
  type        = string
  default     = "web"
}

variable "workspace_id" {
  description = "log analytics workspace"
  type        = string
}

variable "retention_in_days" {
  description = "retention in days"
  type        = number
  default     = 30
}

variable "local_authentication_disabled" {
  description = "local authentication disabled"
  default     = "false"
  type        = bool
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Any tags that should be present on the application insights resources"
}