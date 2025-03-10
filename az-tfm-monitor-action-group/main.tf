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
