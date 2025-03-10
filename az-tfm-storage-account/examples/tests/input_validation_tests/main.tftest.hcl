
provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run storage_account_attribute_actual_vs_expected_test_apply {
  command = apply
    // TODO: Add more unit tests
    assert {
        condition = module.storage.storage_account_name == var.storage_account_name
        error_message = "storage account name is not matching with given variable value"
    }

    assert {
        condition = module.storage.location == var.location
        error_message = "location is not matching with given variable value"
    }

    assert {
        condition = module.storage.account_kind == var.account_kind
        error_message = "account kind is not matching with given variable value"
    }
}

