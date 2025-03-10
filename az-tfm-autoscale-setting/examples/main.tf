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