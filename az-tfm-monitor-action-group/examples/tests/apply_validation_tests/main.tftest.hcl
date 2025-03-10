provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}
run "action_group_actual_attributes_vs_expected_test_apply_validation_tests" {
command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.ag.action_group_name["testactiongroup"] == var.action_group["testactiongroup"].name
    error_message = "action group name does not contain the given variable value"
  }
}