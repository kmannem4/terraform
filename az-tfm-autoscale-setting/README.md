<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to manages a AutoScale Setting which can be applied to SignalR, Servicebus, Virtual Machine Scale Sets, App Services and other scalable resources in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
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
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_emails"></a> [custom\_emails](#input\_custom\_emails) | List of custom email addresses to send notifications to. | `list(string)` | `[]` | no |
| <a name="input_default_capacity"></a> [default\_capacity](#input\_default\_capacity) | The default number of instances. | `string` | n/a | yes |
| <a name="input_enable_notifications"></a> [enable\_notifications](#input\_enable\_notifications) | Enable or disable notifications. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the autoscale setting is enabled. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of the resource group. | `string` | n/a | yes |
| <a name="input_maximum_capacity"></a> [maximum\_capacity](#input\_maximum\_capacity) | The maximum number of instances. | `string` | n/a | yes |
| <a name="input_minimum_capacity"></a> [minimum\_capacity](#input\_minimum\_capacity) | The minimum number of instances. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the autoscale setting. | `string` | n/a | yes |
| <a name="input_profile_name"></a> [profile\_name](#input\_profile\_name) | The name of the autoscale profile. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of autoscale rules. | <pre>list(object({<br>    metric_name        = string<br>    metric_resource_id = string<br>    metric_namespace   = string<br>    time_grain         = string<br>    statistic          = string<br>    time_window        = string<br>    time_aggregation   = string<br>    operator           = string<br>    threshold          = number<br>    scale_actions      = list(object({<br>      direction = string<br>      type      = string<br>      value     = string<br>      cooldown  = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_send_to_subscription_administrator"></a> [send\_to\_subscription\_administrator](#input\_send\_to\_subscription\_administrator) | Send notifications to the subscription administrator. | `bool` | `false` | no |
| <a name="input_send_to_subscription_co_administrator"></a> [send\_to\_subscription\_co\_administrator](#input\_send\_to\_subscription\_co\_administrator) | Send notifications to the subscription co-administrator. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | The ID of the resource to be autoscaled. | `string` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscale_setting_id"></a> [autoscale\_setting\_id](#output\_autoscale\_setting\_id) | The ID of the autoscale setting. |

#### The following resources are created by this module:


- resource.azurerm_monitor_autoscale_setting.autoscale (/usr/agent/azp/_work/1/s/amn-az-tfm-autoscale-setting/main.tf#1)


## Example Scenario

Add AutoScale Setting <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create signalr<br /> - Create servicebus<br /> - Add AutoScale Settings for SignalR & Servicebus

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
# Generate a random string with a length of 5 characters
# consisting of lowercase letters and numbers.
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Define local variables.
locals {
  # Suffixes for resource names.
  resource_group_suffix     = "rg"
  servicebus_suffix         = "svcb"
  signalr_suffix            = "signalr"
  autoscale_setting_suffix  = "scale"
  environment_suffix        = "t01"

  # Mapping of US region names to abbreviations.
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

  # Get the region abbreviation based on the provided location.
  region_abbreviation = local.us_region_abbreviations[var.location]

  # Construct resource names using the region abbreviation and suffixes.
  resource_group_name    = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  signalr_name           = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.signalr_suffix}-${local.environment_suffix}"
  servicebus_name        = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.servicebus_suffix}-${local.environment_suffix}"
  servicebus_autoscale_setting_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.servicebus_suffix}-${local.autoscale_setting_suffix}-${local.environment_suffix}"
  signalr_autoscale_setting_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.signalr_suffix}-${local.autoscale_setting_suffix}-${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
# Module to create a resource group
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0" # Source for the resource group module
  resource_group_name = local.resource_group_name                                                                          # Name of the resource group
  location            = var.location                                                                                       # Location of the resource group
  tags                = var.tags                                                                                           # Tags to assign to the resource group
}

module "servicebus" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on = [module.rg]
  source                        = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-service-bus?ref=v1.0.1"
  resource_group_name           = local.resource_group_name
  tags                          = var.tags
  queue_vars                    = {}
  topic_vars                    = {}
  servicebus_local_auth_enabled = null
  servicebus_name               = local.servicebus_name
  servicebus_location           = var.location
  servicebus_sku_name           = "Premium"
//   servicebus_zone_redundant     = "false"
  servicebus_capacity           = 1
  premium_messaging_partitions  = 1
  minimum_tls_version           = "1.2"
  public_network_access_enabled = "false"
  servicebus_authorization_vars = {}
}

module "signalr" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on = [module.rg]
  source  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-signalr?ref=v1.0.0"

  name                = local.signalr_name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = {
                            name     = "Premium_P1"
                            capacity = 1
                        }
  tags                = var.tags
}

module "servicebus_autoscale" {
  source = "../"       # Source for the autoscale setting module

  name                = local.servicebus_autoscale_setting_name
  resource_group_name = local.resource_group_name
  location            = var.location
  target_resource_id  = module.servicebus.servicebus_namespace_id
  enabled             = true

  profile_name       = "servicebus-profile"
  default_capacity   = "2"
  minimum_capacity   = "1"
  maximum_capacity   = "8"

  rules = [
      {
      metric_name        = "NamespaceCpuUsage"
      metric_resource_id = module.servicebus.servicebus_namespace_id
      metric_namespace   = "microsoft.servicebus/namespaces"
      time_grain         = "PT1M"
      statistic          = "Average"
      time_window        = "PT5M"
      time_aggregation   = "Average"
      operator           = "GreaterThan"
      threshold          = 75
      scale_actions = [
        {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT5M"
        }
      ]
    },
    {
      metric_name        = "NamespaceCpuUsage"
      metric_resource_id = module.servicebus.servicebus_namespace_id
      metric_namespace   = "microsoft.servicebus/namespaces"
      time_grain         = "PT1M"
      statistic          = "Average"
      time_window        = "PT5M"
      time_aggregation   = "Average"
      operator           = "LessThan"
      threshold          = 25
      scale_actions = [
        {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT5M"
        }
      ]
    }
  ]
}

module "signalr_autoscale" {
  source = "../"       # Source for the autoscale setting module

  name                = local.signalr_autoscale_setting_name
  resource_group_name = local.resource_group_name
  location            = var.location
  target_resource_id  = module.signalr.id
  enabled             = true

  profile_name       = "signalr-profile"
  default_capacity   = "1"
  minimum_capacity   = "1"
  maximum_capacity   = "100"

  rules = [
    {
      metric_name        = "ConnectionQuotaUtilization"
      metric_resource_id = module.signalr.id
      metric_namespace   = "microsoft.signalrservice/signalr"
      time_grain         = "PT1M"
      statistic          = "Max"
      time_window        = "PT10M"
      time_aggregation   = "Average"
      operator           = "GreaterThan"
      threshold          = 70
      scale_actions = [
        {
          direction = "Increase"
          type      = "ServiceAllowedNextValue"
          value     = "1"
          cooldown  = "PT5M"
        }
      ]
    },
    {
      metric_name        = "ConnectionQuotaUtilization"
      metric_resource_id = module.signalr.id
      metric_namespace   = "microsoft.signalrservice/signalr"
      time_grain         = "PT1M"
      statistic          = "Max"
      time_window        = "PT10M"
      time_aggregation   = "Average"
      operator           = "LessThan"
      threshold          = 20
      scale_actions = [
        {
          direction = "Decrease"
          type      = "ServiceAllowedNextValue"
          value     = "1"
          cooldown  = "PT5M"
        }
      ]
    },
    {
      metric_name        = "ServerLoad"
      metric_resource_id = module.signalr.id
      metric_namespace   = "microsoft.signalrservice/signalr"
      time_grain         = "PT1M"
      statistic          = "Max"
      time_window        = "PT10M"
      time_aggregation   = "Average"
      operator           = "GreaterThan"
      threshold          = 70
      scale_actions = [
        {
          direction = "Increase"
          type      = "ServiceAllowedNextValue"
          value     = "1"
          cooldown  = "PT5M"
        }
      ]
    },                    
    {
      metric_name        = "ServerLoad"
      metric_resource_id = module.signalr.id
      metric_namespace   = "microsoft.signalrservice/signalr"
      time_grain         = "PT1M"
      statistic          = "Max"
      time_window        = "PT10M"
      time_aggregation   = "Average"
      operator           = "LessThan"
      threshold          = 20
      scale_actions = [
        {
          direction = "Decrease"
          type      = "ServiceAllowedNextValue"
          value     = "1"
          cooldown  = "PT5M"
        }
      ]
    }
  ]
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
# Setting the location for Azure resources
location = "westus2"

# Defining tags to be applied to resources
tags = {
  charge-to       = "101-71200-5000-9500"               # Cost allocation or tracking
  environment     = "test"                              # Environment (e.g., dev, test, prod)
  application     = "Platform Services"                 # Application name
  product         = "Platform Services"                 # Product name
  amnonecomponent = "shared"                            # Component or service 
  role            = "infrastructure-tf-unit-test"       # Role or purpose
  managed-by      = "cloud.engineers@amnhealthcare.com" # Team or individual responsible for management
  owner           = "cloud.engineers@amnhealthcare.com" # Team or individual owning the resource
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->