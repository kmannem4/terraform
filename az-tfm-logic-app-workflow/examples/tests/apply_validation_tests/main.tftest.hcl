provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "logic_app_actual_attributes_vs_expected_test_apply_validation_tests" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition = module.logic_app.logic_app_workflow_name["Test"] == local.test_logic_app_name
    error_message = "The logic app name is not the expected name."
  }
  assert {
    condition = module.logic_app.logic_app_workflow_name["Test1"] == local.test1_logic_app_name
    error_message = "The logic app name is not the expected name."
  }
}
