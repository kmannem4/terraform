
output "servicebus_sku" {
  value = azurerm_servicebus_namespace.servicebus_namespace.sku
}
output "servicebus_location" {
  value = azurerm_servicebus_namespace.servicebus_namespace.location
}

output "servicebus_namespace_id" {
  value = azurerm_servicebus_namespace.servicebus_namespace.id
}
output "servicebus_namespace_name" {
  value = azurerm_servicebus_namespace.servicebus_namespace.name
}

output "servicebus_queue_id" {
  value = { for k, v in azurerm_servicebus_queue.servicebus_queue : k => v.id }
}

output "servicebus_topic_id" {
  value = { for k, v in azurerm_servicebus_topic.servicebus_topic : k => v.id }
}
output "servicebus_topic_subscription_id" {
  value = { for k, v in azurerm_servicebus_subscription.servicebus_subscription : k => v.id }
}

output "servicebus_queues" {
  value = {
    for queue_name, queue_config in var.queue_vars :
    queue_name => {
      queue_name                                 = queue_config.queue_name
      queue_lock_duration                        = queue_config.queue_lock_duration
      queue_max_size_in_megabytes                = queue_config.queue_max_size_in_megabytes
      queue_requires_session                     = queue_config.queue_requires_session
      queue_default_message_ttl                  = queue_config.queue_default_message_ttl
      queue_dead_lettering_on_message_expiration = queue_config.queue_dead_lettering_on_message_expiration
      queue_max_delivery_count                   = queue_config.queue_max_delivery_count
      queue_enable_batched_operations            = queue_config.queue_enable_batched_operations
      queue_auto_delete_on_idle                  = queue_config.queue_auto_delete_on_idle
      queue_enable_partitioning                  = queue_config.queue_enable_partitioning
      queue_enable_express                       = queue_config.queue_enable_express
      queue_authorization_vars = {
        for auth_name, auth_config in queue_config.queue_authorization_vars :
        auth_name => {
          queue_authorization_name   = auth_config.queue_authorization_name
          queue_authorization_listen = auth_config.queue_authorization_listen
          queue_authorization_send   = auth_config.queue_authorization_send
          queue_authorization_manage = auth_config.queue_authorization_manage
        }
      }
    }
  }
}

output "servicebus_topics" {
  value = {
    for topic_name, topic_config in var.topic_vars :
    topic_name => {
      topic_max_size_in_megabytes     = topic_config.topic_max_size_in_megabytes
      topic_name                      = topic_config.topic_name
      topic_status                    = topic_config.topic_status
      topic_default_message_ttl       = topic_config.topic_default_message_ttl
      topic_enable_batched_operations = topic_config.topic_enable_batched_operations
      topic_enable_express            = topic_config.topic_enable_express
      topic_enable_partitioning       = topic_config.topic_enable_partitioning
      topic_support_ordering          = topic_config.topic_support_ordering
      topic_authorization_vars = {
        for auth_name, auth_config in topic_config.topic_authorization_vars :
        auth_name => {
          topic_authorization_name   = auth_config.topic_authorization_name
          topic_authorization_listen = auth_config.topic_authorization_listen
          topic_authorization_send   = auth_config.topic_authorization_send
          topic_authorization_manage = auth_config.topic_authorization_manage
        }
      }
      subscriptions = {
        for sub_name, sub_config in topic_config.subscription_vars :
        sub_name => {
          subscription_name                                      = sub_config.subscription_name
          subscription_max_delivery_count                        = sub_config.subscription_max_delivery_count
          subscription_auto_delete_on_idle                       = sub_config.subscription_auto_delete_on_idle
          subscription_default_message_ttl                       = sub_config.subscription_default_message_ttl
          subscription_lock_duration                             = sub_config.subscription_lock_duration
          subscription_dead_lettering_on_message_expiration      = sub_config.subscription_dead_lettering_on_message_expiration
          subscription_dead_lettering_on_filter_evaluation_error = sub_config.subscription_dead_lettering_on_filter_evaluation_error
          subscription_enable_batched_operations                 = sub_config.subscription_enable_batched_operations
          subscription_requires_session                          = sub_config.subscription_requires_session
          subscription_status                                    = sub_config.subscription_status
        }
      }
    }
  }
}
