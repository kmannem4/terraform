provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "managed_instance_actual_attributes_vs_expected_test_apply_validation_tests" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = { for k, v in module.mssql_mi_server.mssql_mi_output : k => { value = v.name } } == { for k, v in local.managed_instance : k => { value = v.mssql_server_name } }
    error_message = "mssql_mi_server_name is not equal to expected value"
  }
  assert {
    condition = { for k, v in module.mssql_mi_server.mssql_mi_database_output : k => { value = v.name } } == { for k, v in local.managed_instance : k => { value = v.mssql_database_name } }
    error_message = "mssql_database_name is not equal to expected value"
  }
}
