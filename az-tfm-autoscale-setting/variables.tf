variable "name" {
  description = "The name of the autoscale setting."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "target_resource_id" {
  description = "The ID of the resource to be autoscaled."
  type        = string
}

variable "enabled" {
  description = "Whether the autoscale setting is enabled."
  type        = bool
  default     = true
}

variable "profile_name" {
  description = "The name of the autoscale profile."
  type        = string
}

variable "default_capacity" {
  description = "The default number of instances."
  type        = string
}

variable "minimum_capacity" {
  description = "The minimum number of instances."
  type        = string
}

variable "maximum_capacity" {
  description = "The maximum number of instances."
  type        = string
}

variable "rules" {
  description = "A list of autoscale rules."
  type = list(object({
    metric_name        = string
    metric_resource_id = string
    metric_namespace   = string
    time_grain         = string
    statistic          = string
    time_window        = string
    time_aggregation   = string
    operator           = string
    threshold          = number
    scale_actions      = list(object({
      direction = string
      type      = string
      value     = string
      cooldown  = string
    }))
  }))
}

variable "enable_notifications" {
  description = "Enable or disable notifications."
  type        = bool
  default     = false
}

variable "send_to_subscription_administrator" {
  description = "Send notifications to the subscription administrator."
  type        = bool
  default     = false
}

variable "send_to_subscription_co_administrator" {
  description = "Send notifications to the subscription co-administrator."
  type        = bool
  default     = false
}

variable "custom_emails" {
  description = "List of custom email addresses to send notifications to."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}