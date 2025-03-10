provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "actual_vs_expected_test_apply" {
  command = apply

  assert {
    condition     = module.data_factory.data_factory_id != null 
    error_message = "Error: The ID of the Azure Data Factory must not be null."
  }

  assert {
    condition     = module.data_factory.data_factory_outputs.name == var.data_factory_config.data_factory_name
    error_message = "Error: The name of the Azure Data Factory must not be null."
  }

  assert {
    condition     = module.data_factory.data_factory_outputs.public_network_enabled == var.data_factory_config.public_network_enabled
    error_message = "Error: The public network enabled setting does not match the expected value."
  }

  assert {
    condition     = module.data_factory.data_factory_outputs.managed_virtual_network_enabled == var.data_factory_config.managed_virtual_network_enabled
    error_message = "Error: The managed virtual network enabled setting does not match the expected value."
  }

}

