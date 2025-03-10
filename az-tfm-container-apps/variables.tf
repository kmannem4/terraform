variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "container_app_environment_id" {
  description = "Container App Environment ID."
  type        = string
}

variable "container_apps" {
  type = map(object({
    name                  = string
    revision_mode         = string
    workload_profile_name = optional(string)

    template = object({
      max_replicas    = optional(number)
      min_replicas    = optional(number)
      revision_suffix = optional(string)

      init_containers = optional(set(object({
        image   = string
        name    = string
        args    = optional(list(string))
        command = optional(list(string))
        cpu     = optional(number)
        memory  = optional(string)

        env = optional(list(object({
          name        = string
          secret_name = optional(string)
          value       = optional(string)
        })))

        volume_mounts = optional(list(object({
          name = string
          path = string
        })))
      })), [])

      containers = set(object({
        name    = string
        image   = string
        args    = optional(list(string))
        command = optional(list(string))
        cpu     = string
        memory  = string

        env = optional(set(object({
          name        = string
          secret_name = optional(string)
          value       = optional(string)
        })))
        liveness_probe = optional(object({
          port                             = number
          transport                        = string
          failure_count_threshold          = optional(number)
          host                             = optional(string)
          initial_delay                    = optional(number, 1)
          interval_seconds                 = optional(number, 10)
          path                             = optional(string)
          timeout                          = optional(number, 1)
          termination_grace_period_seconds = optional(number)
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        readiness_probe = optional(object({
          port                    = number
          transport               = string
          failure_count_threshold = optional(number)
          host                    = optional(string)
          interval_seconds        = optional(number, 10)
          path                    = optional(string)
          success_count_threshold = optional(number, 3)
          timeout                 = optional(number)
          header = optional(object({
            name  = string
            value = string
          }))
        }))
        startup_probe = optional(object({
          port                             = number
          transport                        = string
          failure_count_threshold          = optional(number)
          host                             = optional(string)
          interval_seconds                 = optional(number, 10)
          path                             = optional(string)
          timeout                          = optional(number)
          termination_grace_period_seconds = optional(number)

          header = optional(object({
            name  = string
            value = string
          }))
        }))
        volume_mounts = optional(list(object({
          name = string
          path = string
        })))
      }))

      azure_queue_scale_rule = optional(object({
        name         = string
        queue_length = number
        queue_name   = string
        authentication = optional(object({
          secret_name       = string
          trigger_parameter = string
        }))
      }))

      custom_scale_rule = optional(object({
        name             = string
        custom_rule_type = string
        metadata         = optional(map(string))
        authentication = optional(object({
          secret_name       = string
          trigger_parameter = string
        }))
      }))

      http_scale_rule = optional(object({
        concurrent_requests = number
        name                = string
        authentication = optional(object({
          secret_name       = string
          trigger_parameter = string
        }))
      }))

      tcp_scale_rule = optional(object({
        concurrent_requests = number
        name                = string
        authentication = optional(object({
          secret_name       = string
          trigger_parameter = string
        }))
      }))

      volume = optional(set(object({
        name         = string
        storage_name = optional(string)
        storage_type = optional(string)
      })))
    })

    dapr = optional(object({
      app_id       = string
      app_port     = number
      app_protocol = optional(string)
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    ingress = optional(object({
      target_port                = number
      allow_insecure_connections = optional(bool, false)
      external_enabled           = optional(bool, false)
      transport                  = optional(string)
      exposed_port               = optional(number)

      traffic_weight = object({
        percentage      = number
        label           = optional(string)
        latest_revision = optional(string)
        revision_suffix = optional(string)
      })

      ip_security_restrictions = optional(list(object({
        action           = string
        ip_address_range = string
        name             = string
        description      = optional(string)
      })), [])
    }))

    registry = optional(list(object({
      server               = string
      username             = optional(string)
      password_secret_name = optional(string)
      identity             = optional(string)
    })))

    secret = optional(list(object({
      name                = string
      value               = optional(string)
      identity            = optional(string)
      key_vault_secret_id = optional(string)
    })))

  }))
  description = "The container apps to deploy."
  nullable    = false

  validation {
    condition     = length(var.container_apps) >= 1
    error_message = "At least one container should be provided."
  }
  validation {
    condition     = alltrue([for n, c in var.container_apps : c.ingress == null ? true : (c.ingress.ip_security_restrictions == null ? true : (length(distinct([for r in c.ingress.ip_security_restrictions : r.action])) <= 1))])
    error_message = "The `action` types in an all `ip_security_restriction` blocks must be the same for the `ingress`, mixing `Allow` and `Deny` rules is not currently supported by the service."
  }
}
