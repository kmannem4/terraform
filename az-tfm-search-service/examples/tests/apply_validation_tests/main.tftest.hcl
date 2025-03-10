provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run attribute_actual_vs_expected_test_apply {
  command = apply
  assert {
    condition     = module.search_service.search_service_name == var.search_service_name
    error_message = "Search Service name is not matching with given variable value"
  }

}
