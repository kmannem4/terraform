provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "diagnostic_setting_attribute_actual_vs_expected_test_apply" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.diagnostic.diagnostic_settings_id != null
    error_message = "Error: The ID of the diagnostic settings must not be null."
  }
  assert {
    condition     = module.diagnostic.target_resource_id != null
    error_message = "Error: The ID of the target resource must not be null."
  }
}