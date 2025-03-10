provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run app_service_plan_attribute_actual_vs_expected_test_apply {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.servicebus.servicebus_namespace_name == var.servicebus_name
    error_message = "Service Bus name is not matching with given variable value"
  }

  assert {
    condition     = module.servicebus.servicebus_location == var.servicebus_location
    error_message = "location is not matching with given variable value"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_name } } == { for k, v in var.queue_vars : k => { value = v.queue_name } }
    error_message = "queue name is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_lock_duration } } == { for k, v in var.queue_vars : k => { value = v.queue_lock_duration } }
    error_message = "queue lock duration is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_max_size_in_megabytes } } == { for k, v in var.queue_vars : k => { value = v.queue_max_size_in_megabytes } }
    error_message = "queue max size_in_megabytes is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_requires_session } } == { for k, v in var.queue_vars : k => { value = v.queue_requires_session } }
    error_message = "queue requires_session is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_default_message_ttl } } == { for k, v in var.queue_vars : k => { value = v.queue_default_message_ttl } }
    error_message = "queue default_message_ttl is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_dead_lettering_on_message_expiration } } == { for k, v in var.queue_vars : k => { value = v.queue_dead_lettering_on_message_expiration } }
    error_message = "queue dead_lettering_on_message_expiration is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_max_delivery_count } } == { for k, v in var.queue_vars : k => { value = v.queue_max_delivery_count } }
    error_message = "queue max_delivery_count is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_enable_batched_operations } } == { for k, v in var.queue_vars : k => { value = v.queue_enable_batched_operations } }
    error_message = "queue enable_batched_operations is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_auto_delete_on_idle } } == { for k, v in var.queue_vars : k => { value = v.queue_auto_delete_on_idle } }
    error_message = "queue auto_delete_on_idle is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_enable_partitioning } } == { for k, v in var.queue_vars : k => { value = v.queue_enable_partitioning } }
    error_message = "queue enable_partitioning is not same as given in variable"
  }
  assert {
    condition     = { for k, v in module.servicebus.servicebus_queues : k => { value = v.queue_enable_express } } == { for k, v in var.queue_vars : k => { value = v.queue_enable_express } }
    error_message = "queue enable_express is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.servicebus.servicebus_topics : k => { value = v.topic_name } } == { for k, v in var.topic_vars : k => { value = v.topic_name } }
    error_message = "topic name is not same as given in variable"
  }
  assert {
    condition     = { for k, v in module.servicebus.servicebus_topics : k => { value = v.topic_default_message_ttl } } == { for k, v in var.topic_vars : k => { value = v.topic_default_message_ttl } }
    error_message = "topic default_message_ttl is not same as given in variable"
  }
  assert {
    condition     = { for k, v in module.servicebus.servicebus_topics : k => { value = v.topic_enable_batched_operations } } == { for k, v in var.topic_vars : k => { value = v.topic_enable_batched_operations } }
    error_message = "topic enable_batched_operations is not same as given in variable"
  }
  assert {
    condition     = { for k, v in module.servicebus.servicebus_topics : k => { value = v.topic_enable_express } } == { for k, v in var.topic_vars : k => { value = v.topic_enable_express } }
    error_message = "topic enable_express is not same as given in variable"
  }
  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_max_delivery_count == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_max_delivery_count
        ])
    ])
    error_message = "Subscription max_delivery_count is not consistent between the actual and expected configurations."
  }
  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_auto_delete_on_idle == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_auto_delete_on_idle
        ])
    ])
    error_message = "subscription auto_delete_on_idle is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_default_message_ttl == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_default_message_ttl
        ])
    ])
    error_message = "subscription default_message_ttl is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_lock_duration == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_lock_duration
        ])
    ])
    error_message = "subscription lock_duration is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_dead_lettering_on_message_expiration == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_dead_lettering_on_message_expiration
        ])
    ])
    error_message = "subscription dead_lettering_on_message_expiration is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_dead_lettering_on_filter_evaluation_error == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_dead_lettering_on_filter_evaluation_error
        ])
    ])
    error_message = "subscription dead_lettering_on_filter_evaluation_error is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_enable_batched_operations == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_enable_batched_operations
        ])
    ])
    error_message = "subscription enable_batched_operations is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_requires_session == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_requires_session
        ])
    ])
    error_message = "subscription requires_session is not consistent between the actual and expected configurations."
  }

  assert {
    condition = alltrue([
      for topic_name, topic_config in var.topic_vars : 
        alltrue([
          for subscription_name, subscription_config in topic_config.subscription_vars : 
            subscription_config.subscription_status == module.servicebus.servicebus_topics[topic_name].subscriptions[subscription_name].subscription_status
        ])
    ])
    error_message = "subscription status is not consistent between the actual and expected configurations."
  }
}


