<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage service bus in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
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
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure location. | `string` | `"westcentralus"` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | minimum tls version | `string` | n/a | yes |
| <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions) | premium messaging partitions | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | public network access enabled | `string` | n/a | yes |
| <a name="input_queue_vars"></a> [queue\_vars](#input\_queue\_vars) | Map of variables for queue | <pre>map(object({<br>    queue_name                                 = string<br>    queue_enable_partitioning                  = string<br>    queue_lock_duration                        = string<br>    queue_max_size_in_megabytes                = string<br>    queue_requires_session                     = string<br>    queue_default_message_ttl                  = string<br>    queue_dead_lettering_on_message_expiration = string<br>    queue_max_delivery_count                   = string<br>    queue_enable_batched_operations            = string<br>    queue_auto_delete_on_idle                  = string<br>    queue_enable_express                       = string<br>    queue_authorization_vars = map(object({<br>      queue_authorization_name   = string<br>      queue_authorization_listen = bool<br>      queue_authorization_send   = bool<br>      queue_authorization_manage = bool<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_servicebus_authorization_vars"></a> [servicebus\_authorization\_vars](#input\_servicebus\_authorization\_vars) | n/a | <pre>map(object({<br>    servicebus_authorization_name   = string<br>    servicebus_authorization_listen = bool<br>    servicebus_authorization_send   = bool<br>    servicebus_authorization_manage = bool<br>  }))</pre> | n/a | yes |
| <a name="input_servicebus_capacity"></a> [servicebus\_capacity](#input\_servicebus\_capacity) | servicebus capacity | `string` | n/a | yes |
| <a name="input_servicebus_local_auth_enabled"></a> [servicebus\_local\_auth\_enabled](#input\_servicebus\_local\_auth\_enabled) | servicebus local auth enabled | `string` | n/a | yes |
| <a name="input_servicebus_location"></a> [servicebus\_location](#input\_servicebus\_location) | servicebus location | `string` | n/a | yes |
| <a name="input_servicebus_name"></a> [servicebus\_name](#input\_servicebus\_name) | service bus name | `string` | n/a | yes |
| <a name="input_servicebus_sku_name"></a> [servicebus\_sku\_name](#input\_servicebus\_sku\_name) | servicebus sku name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |
| <a name="input_topic_vars"></a> [topic\_vars](#input\_topic\_vars) | Map of variables for topics | <pre>map(object({<br>    topic_max_size_in_megabytes     = number<br>    topic_name                      = string<br>    topic_status                    = string<br>    topic_default_message_ttl       = string<br>    topic_enable_batched_operations = string<br>    topic_enable_express            = string<br>    topic_enable_partitioning       = string<br>    topic_support_ordering          = string<br>    topic_authorization_vars = map(object({<br>      topic_authorization_name   = string<br>      topic_authorization_listen = bool<br>      topic_authorization_send   = bool<br>      topic_authorization_manage = bool<br>    }))<br>    subscription_vars = map(object({<br>      subscription_name                                      = string<br>      subscription_max_delivery_count                        = string<br>      subscription_auto_delete_on_idle                       = string<br>      subscription_default_message_ttl                       = string<br>      subscription_lock_duration                             = string<br>      subscription_dead_lettering_on_message_expiration      = string<br>      subscription_dead_lettering_on_filter_evaluation_error = string<br>      subscription_enable_batched_operations                 = string<br>      subscription_requires_session                          = string<br>      subscription_status                                    = string<br>    }))<br>  }))</pre> | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_servicebus_location"></a> [servicebus\_location](#output\_servicebus\_location) | n/a |
| <a name="output_servicebus_namespace_id"></a> [servicebus\_namespace\_id](#output\_servicebus\_namespace\_id) | n/a |
| <a name="output_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#output\_servicebus\_namespace\_name) | n/a |
| <a name="output_servicebus_queue_id"></a> [servicebus\_queue\_id](#output\_servicebus\_queue\_id) | n/a |
| <a name="output_servicebus_queues"></a> [servicebus\_queues](#output\_servicebus\_queues) | n/a |
| <a name="output_servicebus_sku"></a> [servicebus\_sku](#output\_servicebus\_sku) | n/a |
| <a name="output_servicebus_topic_id"></a> [servicebus\_topic\_id](#output\_servicebus\_topic\_id) | n/a |
| <a name="output_servicebus_topic_subscription_id"></a> [servicebus\_topic\_subscription\_id](#output\_servicebus\_topic\_subscription\_id) | n/a |
| <a name="output_servicebus_topics"></a> [servicebus\_topics](#output\_servicebus\_topics) | n/a |

#### The following resources are created by this module:


- resource.azurerm_servicebus_namespace.servicebus_namespace (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#76)
- resource.azurerm_servicebus_namespace_authorization_rule.servicebus_authorizationrule (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#92)
- resource.azurerm_servicebus_queue.servicebus_queue (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#103)
- resource.azurerm_servicebus_queue_authorization_rule.example (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#123)
- resource.azurerm_servicebus_subscription.servicebus_subscription (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#166)
- resource.azurerm_servicebus_topic.servicebus_topic (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#136)
- resource.azurerm_servicebus_topic_authorization_rule.example (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#153)
- data source.azurerm_client_config.current (/usr/agent/azp/_work/1/s/amn-az-tfm-service-bus/main.tf#2)


## Example Scenario

Create service bus <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create service bus

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  environment_suffix    = "t01"
  us_region_abbreviations = {
    centralus      = "cus"
    eastus         = "eus"
    eastus2        = "eus2"
    westus         = "wus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westcentralus  = "wcus"
    westus2        = "wus2"
  }
  region_abbreviation = local.us_region_abbreviations[var.location]
  resource_group_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "servicebus" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on                    = [module.rg]
  source                        = "../"
  resource_group_name           = local.resource_group_name
  queue_vars                    = var.queue_vars
  topic_vars                    = var.topic_vars
  location                      = var.location
  servicebus_local_auth_enabled = var.servicebus_local_auth_enabled
  servicebus_name               = var.servicebus_name
  servicebus_location           = var.servicebus_location
  servicebus_sku_name           = var.servicebus_sku_name
  servicebus_capacity           = var.servicebus_capacity
  premium_messaging_partitions  = var.premium_messaging_partitions
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  servicebus_authorization_vars = var.servicebus_authorization_vars
  tags                          = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
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
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->