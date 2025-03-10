#DATASOURCE_CLIENT_CONFIG
data "azurerm_client_config" "current" {
}

#---------------------------------
# Local declarations
#---------------------------------

locals {
  location = lower(var.location)
  # Generate lists of configurations for topics, subscriptions, queues, and their authorizations.
  topic_variables_list = [for topic_name, topic_config in var.topic_vars != null ? var.topic_vars : {} : {
    topic_max_size_in_megabytes     = topic_config.topic_max_size_in_megabytes
    topic_name                      = topic_config.topic_name
    topic_status                    = topic_config.topic_status
    topic_default_message_ttl       = topic_config.topic_default_message_ttl
    topic_enable_batched_operations = topic_config.topic_enable_batched_operations
    topic_enable_express            = topic_config.topic_enable_express
    topic_enable_partitioning       = topic_config.topic_enable_partitioning
    topic_support_ordering          = topic_config.topic_support_ordering
    subscriptions = [for subscription_name, subscription_config in topic_config.subscription_vars != null ? topic_config.subscription_vars : {} : {
      subscription_name                                      = subscription_config.subscription_name
      subscription_max_delivery_count                        = subscription_config.subscription_max_delivery_count
      subscription_auto_delete_on_idle                       = subscription_config.subscription_auto_delete_on_idle
      subscription_default_message_ttl                       = subscription_config.subscription_default_message_ttl
      subscription_lock_duration                             = subscription_config.subscription_lock_duration
      subscription_dead_lettering_on_message_expiration      = subscription_config.subscription_dead_lettering_on_message_expiration
      subscription_dead_lettering_on_filter_evaluation_error = subscription_config.subscription_dead_lettering_on_filter_evaluation_error
      subscription_enable_batched_operations                 = subscription_config.subscription_enable_batched_operations
      subscription_requires_session                          = subscription_config.subscription_requires_session
      subscription_status                                    = subscription_config.subscription_status
    }]
    topic_authorizations = [for topic_authorization_name, topic_authorization_config in topic_config.topic_authorization_vars != null ? topic_config.topic_authorization_vars : {} : {
      topic_authorization_name   = topic_authorization_config.topic_authorization_name
      topic_authorization_listen = topic_authorization_config.topic_authorization_listen
      topic_authorization_send   = topic_authorization_config.topic_authorization_send
      topic_authorization_manage = topic_authorization_config.topic_authorization_manage
    }]
  }]
  subscription_variables_list = flatten([
    for k in local.topic_variables_list : [
      for i in k.subscriptions : merge({ "topic_name" = k.topic_name }, i)
    ]
  ])
  topic_authorization_variables_list = flatten([
    for k in local.topic_variables_list : [
      for i in k.topic_authorizations : merge({ "topic_name" = k.topic_name }, i)
    ]
  ])
  queue_variables_list = [for queue_name, queue_config in var.queue_vars != null ? var.queue_vars : {} : {
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
    queue_authorizations = [for queue_authorization_name, queue_authorization_config in queue_config.queue_authorization_vars != null ? queue_config.queue_authorization_vars : {} : {
      queue_authorization_name   = queue_authorization_config.queue_authorization_name
      queue_authorization_listen = queue_authorization_config.queue_authorization_listen
      queue_authorization_send   = queue_authorization_config.queue_authorization_send
      queue_authorization_manage = queue_authorization_config.queue_authorization_manage
    }]
  }]
  queue_authorization_variables_list = flatten([
    for k in local.queue_variables_list : [
      for i in k.queue_authorizations : merge({ "queue_name" = k.queue_name }, i)
    ]
  ])
}

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  #checkov:skip=CKV_AZURE_199: skip
  #checkov:skip=CKV_AZURE_201: skip
  #checkov:skip=CKV_AZURE_202: not using managed identity
  resource_group_name           = var.resource_group_name
  name                          = var.servicebus_name
  location                      = var.servicebus_location
  sku                           = var.servicebus_sku_name
  capacity                      = var.servicebus_capacity
  local_auth_enabled            = var.servicebus_local_auth_enabled
  premium_messaging_partitions  = var.premium_messaging_partitions
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus_authorizationrule" {
  depends_on   = [azurerm_servicebus_namespace.servicebus_namespace]
  for_each     = var.servicebus_authorization_vars
  name         = each.value.servicebus_authorization_name
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
  listen       = each.value.servicebus_authorization_listen
  send         = each.value.servicebus_authorization_send
  manage       = each.value.servicebus_authorization_manage
}

# Provision Service Bus queues.
resource "azurerm_servicebus_queue" "servicebus_queue" {
  depends_on = [azurerm_servicebus_namespace.servicebus_namespace]
  for_each = { for entry in local.queue_variables_list :
    entry.queue_name => entry
  }
  name                                 = each.value.queue_name
  namespace_id                         = azurerm_servicebus_namespace.servicebus_namespace.id
  partitioning_enabled                 = each.value.queue_enable_partitioning
  lock_duration                        = each.value.queue_lock_duration
  max_size_in_megabytes                = each.value.queue_max_size_in_megabytes
  requires_session                     = each.value.queue_requires_session
  default_message_ttl                  = each.value.queue_default_message_ttl
  dead_lettering_on_message_expiration = each.value.queue_dead_lettering_on_message_expiration
  max_delivery_count                   = each.value.queue_max_delivery_count
  batched_operations_enabled           = each.value.queue_enable_batched_operations
  auto_delete_on_idle                  = each.value.queue_auto_delete_on_idle
  express_enabled                      = each.value.queue_enable_express
}

# Create authorization rules for Service Bus queues.
resource "azurerm_servicebus_queue_authorization_rule" "example" {
  depends_on = [azurerm_servicebus_queue.servicebus_queue]
  for_each = { for entry in local.queue_authorization_variables_list :
    entry.queue_name => entry
  }
  name     = each.value.queue_authorization_name
  queue_id = azurerm_servicebus_queue.servicebus_queue[each.key].id
  listen   = each.value.queue_authorization_listen
  send     = each.value.queue_authorization_send
  manage   = each.value.queue_authorization_manage
}

# Provision Service Bus topics.
resource "azurerm_servicebus_topic" "servicebus_topic" {
  depends_on = [azurerm_servicebus_queue.servicebus_queue]
  for_each = { for entry in local.topic_variables_list :
    entry.topic_name => entry
  }
  name                       = each.value.topic_name
  namespace_id               = azurerm_servicebus_namespace.servicebus_namespace.id
  max_size_in_megabytes      = each.value.topic_max_size_in_megabytes
  status                     = each.value.topic_status
  default_message_ttl        = each.value.topic_default_message_ttl
  batched_operations_enabled = each.value.topic_enable_batched_operations
  express_enabled            = each.value.topic_enable_express
  partitioning_enabled       = each.value.topic_enable_partitioning
  support_ordering           = each.value.topic_support_ordering
}

# Create authorization rules for Service Bus topics.
resource "azurerm_servicebus_topic_authorization_rule" "example" {
  depends_on = [azurerm_servicebus_topic.servicebus_topic]
  for_each = { for entry in local.topic_authorization_variables_list :
    entry.topic_name => entry
  }
  name     = each.value.topic_authorization_name
  topic_id = azurerm_servicebus_topic.servicebus_topic[each.key].id
  listen   = each.value.topic_authorization_listen
  send     = each.value.topic_authorization_send
  manage   = each.value.topic_authorization_manage
}

# Provision Service Bus subscriptions.
resource "azurerm_servicebus_subscription" "servicebus_subscription" {
  depends_on = [azurerm_servicebus_topic.servicebus_topic]
  for_each = {
    for k in local.subscription_variables_list :
    "${k.topic_name},${k.subscription_name}" => k
  }
  name                                      = each.value.subscription_name
  topic_id                                  = azurerm_servicebus_topic.servicebus_topic[each.value.topic_name].id
  max_delivery_count                        = each.value.subscription_max_delivery_count
  auto_delete_on_idle                       = each.value.subscription_auto_delete_on_idle
  default_message_ttl                       = each.value.subscription_default_message_ttl
  lock_duration                             = each.value.subscription_lock_duration
  dead_lettering_on_message_expiration      = each.value.subscription_dead_lettering_on_message_expiration
  dead_lettering_on_filter_evaluation_error = each.value.subscription_dead_lettering_on_filter_evaluation_error
  batched_operations_enabled                = each.value.subscription_enable_batched_operations
  requires_session                          = each.value.subscription_requires_session
  status                                    = each.value.subscription_status
}
