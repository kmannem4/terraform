provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run container_app_environment_attribute_actual_vs_expected_test_apply {
    command = apply
    assert {
        condition = module.container_app_environment.container_app_environment_name["Test"] == local.container_app_environment_name
        error_message = "container app environment name is not matching with given variable value"
    }
}    