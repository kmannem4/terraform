<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage action group in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = lower(var.resource_group_name)
}
#------------------------------------------------------------------------------
# Azure Resource Group Module
#------------------------------------------------------------------------------
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  count               = var.create_resource_group ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "action_group" {
  for_each            = var.action_group
  name                = each.value.name
  resource_group_name = var.create_resource_group ? module.rg[0].resource_group_name : data.azurerm_resource_group.rgrp[0].name
  short_name          = each.value.short_name
  tags                = var.tags
  enabled             = each.value.action
  dynamic "arm_role_receiver" {
    for_each = each.value.armrole_receivers != null ? each.value.armrole_receivers : []
    content {
      name                    = arm_role_receiver.value.name
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = arm_role_receiver.value.use_common_alert_schema
    }
  }
  dynamic "automation_runbook_receiver" {
    for_each = each.value.automation_runbook_receiver != null ? each.value.automation_runbook_receiver : []
    content {
      name                  = automation_runbook_receiver.value.name
      service_uri           = automation_runbook_receiver.value.service_uri
      automation_account_id = automation_runbook_receiver.value.automation_account_id
      runbook_name          = automation_runbook_receiver.value.runbook_name
      webhook_resource_id   = automation_runbook_receiver.value.webhook_resource_id
      is_global_runbook     = automation_runbook_receiver.value.is_global_runbook
    }
  }
  dynamic "azure_app_push_receiver" {
    for_each = each.value.azure_app_push_receiver != null ? each.value.azure_app_push_receiver : []
    content {
      name          = azure_app_push_receiver.value.name
      email_address = azure_app_push_receiver.value.email_address
    }
  }
  dynamic "arm_role_receiver" {
    for_each = each.value.armrole_receivers != null ? each.value.armrole_receivers : []
    content {
      name                    = arm_role_receiver.value.name
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = arm_role_receiver.value.use_common_alert_schema
    }
  }
  dynamic "azure_function_receiver" {
    for_each = each.value.azure_function_receiver != null ? each.value.azure_function_receiver : []
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
    }
  }
  dynamic "email_receiver" {
    for_each = each.value.email_receivers != null ? each.value.email_receivers : []
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }
  dynamic "event_hub_receiver" {
    for_each = each.value.event_hub_receiver != null ? each.value.event_hub_receiver : []
    content {
      name                    = event_hub_receiver.value.name
      event_hub_name          = event_hub_receiver.value.event_hub_name
      event_hub_namespace     = event_hub_receiver.value.event_hub_namespace
      subscription_id         = event_hub_receiver.value.subscription_id
      tenant_id               = event_hub_receiver.value.tenant_id
      use_common_alert_schema = event_hub_receiver.value.use_common_alert_schema
    }
  }
  dynamic "itsm_receiver" {
    for_each = each.value.itsm_receiver != null ? each.value.itsm_receiver : []
    content {
      name                 = itsm_receiver.value.name
      workspace_id         = itsm_receiver.value.workspace_id
      connection_id        = itsm_receiver.value.connection_id
      ticket_configuration = itsm_receiver.value.ticket_configuration
      region               = itsm_receiver.value.region
    }
  }
  dynamic "logic_app_receiver" {
    for_each = each.value.logic_app_receiver != null ? each.value.logic_app_receiver : []
    content {
      name         = logic_app_receiver.value.name
      resource_id  = logic_app_receiver.value.resource_id
      callback_url = logic_app_receiver.value.callback_url
    }
  }
  dynamic "sms_receiver" {
    for_each = each.value.sms_receivers != null ? each.value.sms_receivers : []
    content {
      name         = sms_receiver.value.name
      phone_number = sms_receiver.value.phone_number
      country_code = sms_receiver.value.country_code
    }
  }
  dynamic "voice_receiver" {
    for_each = each.value.voice_receivers != null ? each.value.voice_receivers : []
    content {
      name         = voice_receiver.value.name
      phone_number = voice_receiver.value.phone_number
      country_code = voice_receiver.value.country_code
    }
  }

  dynamic "webhook_receiver" {
    for_each = each.value.webhook_receiver != null ? each.value.webhook_receiver : []
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = webhook_receiver.value.use_common_alert_schema
    }
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group"></a> [action\_group](#input\_action\_group) | A map of objects representing action group configurations. | <pre>map(object({<br>    name       = string<br>    short_name = string<br>    location   = optional(string)<br>    action     = optional(bool)<br>    armrole_receivers = optional(list(object({<br>      name                    = string<br>      role_id                 = string<br>      use_common_alert_schema = bool<br>    })))<br>    automation_runbook_receiver = optional(list(object({<br>      name                    = string<br>      automation_account_id   = string<br>      runbook_name            = string<br>      webhook_resource_id     = string<br>      is_global_runbook       = bool<br>      service_uri             = optional(string)<br>      use_common_alert_schema = optional(bool)<br>    })))<br>    azure_app_push_receiver = optional(list(object({<br>      name          = string<br>      email_address = string<br>    })))<br>    azure_function_receiver = optional(list(object({<br>      name                     = string<br>      function_app_resource_id = string<br>      function_name            = string<br>      http_trigger_url         = string<br>      use_common_alert_schema  = bool<br>    })))<br>    email_receivers = optional(list(object({<br>      name                    = string<br>      email_address           = string<br>      use_common_alert_schema = bool<br>    })))<br>    event_hub_receiver = optional(list(object({<br>      name                    = string<br>      event_hub_name          = string<br>      event_hub_namespace     = string<br>      subscription_id         = optional(string)<br>      tenant_id               = string<br>      use_common_alert_schema = bool<br>    })))<br>    itsm_receiver = optional(list(object({<br>      name                 = string<br>      workspace_id         = string<br>      connection_id        = string<br>      ticket_configuration = string<br>      region               = string<br>    })))<br>    logic_app_receiver = optional(list(object({<br>      name                    = string<br>      callback_url            = string<br>      resource_id             = string<br>      use_common_alert_schema = bool<br>    })))<br>    sms_receivers = optional(list(object({<br>      name         = string<br>      country_code = number<br>      phone_number = number<br>    })))<br>    voice_receivers = optional(list(object({<br>      name         = string<br>      country_code = number<br>      phone_number = number<br>    })))<br>    webhook_receiver = optional(list(object({<br>      name                    = string<br>      service_uri             = string<br>      use_common_alert_schema = bool<br>      aad_auth = object({<br>        object_id      = string<br>        identifier_uri = string<br>        tenant_id      = string<br>      })<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | value to create resource group | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | location off the resource group | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the created action group. |
| <a name="output_action_group_name"></a> [action\_group\_name](#output\_action\_group\_name) | value of the action group name |

#### The following resources are created by this module:


- resource.azurerm_monitor_action_group.action_group (/usr/agent/azp/_work/1/s/amn-az-tfm-monitor-action-group/main.tf#21)
- data source.azurerm_resource_group.rgrp (/usr/agent/azp/_work/1/s/amn-az-tfm-monitor-action-group/main.tf#5)


## Example Scenario

Create action group <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br />  - Create action group

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
# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}
module "ag" {
  depends_on          = [module.rg]
  source              = "../"
  action_group        = var.action_group
  resource_group_name = local.resource_group_name
  location            = var.location
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl

location = "westus2"
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
action_group = {
  testactiongroup = {
    "name"       = "testactiongroup"
    "short_name" = "testag"
    "email_receivers" = [{
      "name"                    = "test_email_receiver"
      "email_address"           = "test@test.com"
      "use_common_alert_schema" = true
    }],
    "location" = "global"
  }
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->