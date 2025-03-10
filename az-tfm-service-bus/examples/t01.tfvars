location = "westcentralus"
tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "Platform Services",
  product         = "Platform Services",
  amnonecomponent = "shared",
  role            = "infrastructure-tf-unit-test",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}
servicebus_name               = "co-wus2-tftest-svcb-t04"
servicebus_location           = "westcentralus"
servicebus_sku_name           = "Premium"
servicebus_capacity           = "2"
servicebus_local_auth_enabled = "true"
minimum_tls_version           = "1.2"
public_network_access_enabled = "false"
premium_messaging_partitions  = "2"

#servicebus_authorization_vars 
servicebus_authorization_vars = {
  "servicebus_authorization_1" = { # can add multiple blocks similar to servicebus_authorization_1 ex: servicebus_authorization_2 , servicebus_authorization_3 etc to create multiple servicebus authorization
    servicebus_authorization_name   = "amnone-placementautomation-func"
    servicebus_authorization_listen = true
    servicebus_authorization_send   = true
    servicebus_authorization_manage = false
  }
  # ,
  # "servicebus_authorization_2" = {  # can add multiple blocks similar to servicebus_authorization_1 ex: servicebus_authorization_2 , servicebus_authorization_3 etc to create multiple servicebus authorization
  #   servicebus_authorization_name   = "amnone-placementautomation-func1"
  #   servicebus_authorization_listen = true
  #   servicebus_authorization_send   = true
  #   servicebus_authorization_manage = false
  # }
}

queue_vars = {
  "queue_1" = { # can add multiple blocks similar to queue_1 ex: queue_2 , queue_3 etc to create multiple queues
    queue_name                                 = "co-ws2-amnshared-svcbq-01"
    queue_lock_duration                        = "PT30S"
    queue_max_size_in_megabytes                = "4096"
    queue_requires_session                     = "false"
    queue_default_message_ttl                  = "P14D"
    queue_dead_lettering_on_message_expiration = "false"
    queue_max_delivery_count                   = "10"
    queue_enable_batched_operations            = "true"
    queue_auto_delete_on_idle                  = "P10675199DT2H48M5.4775807S"
    queue_enable_partitioning                  = "true"
    queue_enable_express                       = "false"
    queue_authorization_vars = {
      "queue_authorization_1" = { # can add multiple blocks similar to queue_authorization_1 ex: queue_authorization_2 , queue_authorization_3 etc to create multiple queue authorization
        queue_authorization_name   = "amnone-placementautomation-func"
        queue_authorization_listen = true
        queue_authorization_send   = false
        queue_authorization_manage = false
      }
    }
  }
  # ,
  # "queue_2" = {  # can add multiple blocks similar to queue_1 ex: queue_2 , queue_3 etc to create multiple queues
  #   queue_name                                 = "co-ws2-amnshared-svcbq-02"
  #   queue_lock_duration                        = "PT30S"
  #   queue_max_size_in_megabytes                = "4096"
  #   queue_requires_session                     = "false"
  #   queue_default_message_ttl                  = "P14D"
  #   queue_dead_lettering_on_message_expiration = "false"
  #   queue_max_delivery_count                   = "10"
  #   queue_enable_batched_operations            = "true"
  #   queue_auto_delete_on_idle                  = "P10675199DT2H48M5.4775807S"
  #   queue_enable_partitioning                  = "true"
  #   queue_enable_express                       = "false"
  #   queue_authorization_vars = {
  #     "queue_authorization_2" = { # can add multiple blocks similar to queue_authorization_1 ex: queue_authorization_2 , queue_authorization_3 etc to create multiple queue authorization
  #       queue_authorization_name   = "amnone-placementautomation-func"
  #       queue_authorization_listen = true
  #       queue_authorization_send   = false
  #       queue_authorization_manage = false
  #     }
  #   }
  # }
}

topic_vars = {
  "topic_1" = { # can add multiple blocks similar to topic_1 ex: topic_2 , topic_3 etc to create multiple topics
    topic_max_size_in_megabytes     = 4096
    topic_name                      = "amie-amhdb-dbo-audit-cdc"
    topic_status                    = "Active"
    topic_default_message_ttl       = "P14D"
    topic_enable_batched_operations = "true"
    topic_enable_express            = "false"
    topic_enable_partitioning       = "true"
    topic_support_ordering          = "true"
    topic_authorization_vars = {
      "topic_authorization_1" = { # can add multiple blocks similar to topic_authorization_1 ex: topic_authorization_2 , topic_authorization_3 etc to create multiple topic authorization
        topic_authorization_name   = "amnone-placementautomation-func"
        topic_authorization_listen = true
        topic_authorization_send   = false
        topic_authorization_manage = false
      }
    }
    subscription_vars = {
      "subscription_1" = { # can add multiple blocks similar to subscription_1 ex: subscription_2 , subscription_3 etc to create multiple subscriptions
        subscription_name                                      = "amnone-placementautomation-func"
        subscription_max_delivery_count                        = "10"
        subscription_auto_delete_on_idle                       = "P10675199DT2H48M5.4775807S"
        subscription_default_message_ttl                       = "P14D"
        subscription_lock_duration                             = "PT90S"
        subscription_dead_lettering_on_message_expiration      = "true"
        subscription_dead_lettering_on_filter_evaluation_error = "false"
        subscription_enable_batched_operations                 = "true"
        subscription_requires_session                          = "false"
        subscription_status                                    = "Active"
      }
    }
  }
}
