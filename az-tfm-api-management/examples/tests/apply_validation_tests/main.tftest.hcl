provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}
run "apim_actual_attributes_vs_expected_test_apply_validation_tests" {
command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.apim.api_management_name == local.api_management.name
    error_message = "APIM name does not contain the given variable value"
  }
}