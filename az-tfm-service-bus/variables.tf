variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure location."
  default     = "westcentralus"
  type        = string
}

variable "tags" {
  validation {
    condition     = length(keys(var.tags)) <= 15
    error_message = "The number of tags must not exceed 15."
  }
}

variable "servicebus_name" {
  description = "service bus name"
  type        = string
}

variable "servicebus_location" {
  description = "servicebus location"
  type        = string
}
variable "servicebus_sku_name" {
  description = "servicebus sku name"
  type        = string
}
variable "servicebus_capacity" {
  description = "servicebus capacity"
  type        = string
}
variable "servicebus_local_auth_enabled" {
  description = "servicebus local auth enabled"
  type        = string
}
variable "minimum_tls_version" {
  description = "minimum tls version"
  type        = string
}
variable "public_network_access_enabled" {
  description = "public network access enabled"
  type        = string
}

variable "premium_messaging_partitions" {
  description = "premium messaging partitions"
  type        = string
}

variable "servicebus_authorization_vars" {
  type = map(object({
    servicebus_authorization_name   = string
    servicebus_authorization_listen = bool
    servicebus_authorization_send   = bool
    servicebus_authorization_manage = bool
  }))
}
variable "queue_vars" {
  type = map(object({
    queue_name                                 = string
    queue_enable_partitioning                  = string
    queue_lock_duration                        = string
    queue_max_size_in_megabytes                = string
    queue_requires_session                     = string
    queue_default_message_ttl                  = string
    queue_dead_lettering_on_message_expiration = string
    queue_max_delivery_count                   = string
    queue_enable_batched_operations            = string
    queue_auto_delete_on_idle                  = string
    queue_enable_express                       = string
    queue_authorization_vars = map(object({
      queue_authorization_name   = string
      queue_authorization_listen = bool
      queue_authorization_send   = bool
      queue_authorization_manage = bool
    }))
  }))
  description = "Map of variables for queue"
  default     = {}
}

variable "topic_vars" {
  type = map(object({
    topic_max_size_in_megabytes     = number
    topic_name                      = string
    topic_status                    = string
    topic_default_message_ttl       = string
    topic_enable_batched_operations = string
    topic_enable_express            = string
    topic_enable_partitioning       = string
    topic_support_ordering          = string
    topic_authorization_vars = map(object({
      topic_authorization_name   = string
      topic_authorization_listen = bool
      topic_authorization_send   = bool
      topic_authorization_manage = bool
    }))
    subscription_vars = map(object({
      subscription_name                                      = string
      subscription_max_delivery_count                        = string
      subscription_auto_delete_on_idle                       = string
      subscription_default_message_ttl                       = string
      subscription_lock_duration                             = string
      subscription_dead_lettering_on_message_expiration      = string
      subscription_dead_lettering_on_filter_evaluation_error = string
      subscription_enable_batched_operations                 = string
      subscription_requires_session                          = string
      subscription_status                                    = string
    }))
  }))
  description = "Map of variables for topics "
  default     = {}
}
