provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run application_insights_attribute_actual_vs_expected_test_apply {
    command = apply
    // TODO: Add more unit tests
    assert {
      condition     = module.application_insights.application_insight_name == var.application_insight_name
      error_message = "Error: Application insight name is not matching with given variable value"
           }
    assert {
      condition = module.application_insights.location == var.location
      error_message = "Error: location is not matching with given variable value"
    }
    assert {
      condition     = module.application_insights.retention_in_days == var.retention_in_days
      error_message = "Error: retention in days is not matching with given variable value"
           }
    assert {
      condition = module.application_insights.local_authentication_disabled == var.local_authentication_disabled
      error_message = "Error: local authentication disabled is not matching with given variable value"
    }
    assert {
      condition = module.application_insights.application_type == var.application_type
      error_message = "Error: application type is not matching with given variable value"
    }
}
