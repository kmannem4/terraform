
provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run cosmosdb_account_attribute_actual_vs_expected_test_apply {
    command = apply
    // TODO: Add more unit tests
    assert {
        condition = module.cosmons_db_account.cosmos_db_account_name == var.cosmos_db_account_name
        error_message = "cosmosdb name is not matching with given variable value"
    }

    assert {
        condition = module.cosmons_db_account.cosmons_db_account_kind == var.kind
        error_message = "cosmosdb kind is not matching with given variable value"
    }
}
