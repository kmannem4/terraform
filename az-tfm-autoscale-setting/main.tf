resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = var.target_resource_id
  enabled             = var.enabled
  tags                = var.tags

  profile {
    name = var.profile_name

    capacity {
      default = var.default_capacity
      minimum = var.minimum_capacity
      maximum = var.maximum_capacity
    }

    dynamic "rule" {
      for_each = var.rules
      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = rule.value.metric_resource_id
          time_grain         = rule.value.time_grain
          statistic          = rule.value.statistic
          time_window        = rule.value.time_window
          time_aggregation   = rule.value.time_aggregation
          operator           = rule.value.operator
          threshold          = rule.value.threshold
        }

        dynamic "scale_action" {
          for_each = rule.value.scale_actions
          content {
            direction = scale_action.value.direction
            type      = scale_action.value.type
            value     = scale_action.value.value
            cooldown  = scale_action.value.cooldown
          }
        }
      }
    }
  }

  dynamic "notification" {
    for_each = var.enable_notifications ? [1] : []
    content {
      email {
        send_to_subscription_administrator    = var.send_to_subscription_administrator
        send_to_subscription_co_administrator = var.send_to_subscription_co_administrator
        custom_emails                         = var.custom_emails
      }
    }
  }
}