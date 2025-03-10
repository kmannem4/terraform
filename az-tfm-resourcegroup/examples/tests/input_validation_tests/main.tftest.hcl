provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "plan_RG_location_validation_unit_test" {
  command = plan
  // TODO: Add more unit tests
  assert {
    condition     = module.rg.location == var.location
    error_message = "Resource group location is not matching with the given variable value"
  }
}

run "plan_rg_tags_validation_unit_test" {
  command = plan
  // TODO: Add more unit tests
  assert {
    condition     = length(var.tags) > 0
    error_message = "Please Provide tags, it should be not empty!!"
  }
}

run "apply_validation_unit_test" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.rg.location == var.location
    error_message = "Resource group location is not matching with the given variable value"
  }
}