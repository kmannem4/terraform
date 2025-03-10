provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "autoscale_setting_attribute_actual_vs_expected_test_apply" {
  command = apply

  // TODO: Add more unit tests
  assert {
    condition     = module.servicebus_autoscale.autoscale_setting_id != null
    error_message = "Error: The ID of the Service Bus autoscale settings must not be null."
  }

  assert {
    condition     = module.signalr_autoscale.autoscale_setting_id != null
    error_message = "Error: The ID of the SignalR autoscale settings must not be null."
  }

  assert {
    condition     = module.servicebus_autoscale.autoscale_setting_name == local.servicebus_autoscale_setting_name
    error_message = "Error: Name of the Service Bus autoscale settings is not valid."
  }

  assert {
    condition     = module.signalr_autoscale.autoscale_setting_name == local.signalr_autoscale_setting_name
    error_message = "Error: Name of the SignalR autoscale settings is not valid."
  }

  assert {
    condition     = module.servicebus_autoscale.autoscale_setting_target_resource_id == module.servicebus.servicebus_namespace_id
    error_message = "Error: Target resource of the Service Bus autoscale settings is not valid."
  }

  assert {
    condition     = module.signalr_autoscale.autoscale_setting_target_resource_id == module.signalr.id
    error_message = "Error: Target resource of the SignalR autoscale settings is not valid."
  }
}