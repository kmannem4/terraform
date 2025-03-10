provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}
 
run "input_validation_unit_test" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.rg.location == var.location
    error_message = "Resource group location is not matching with the given variable value"
  }
  assert {
    condition     = module.mssql_server.mssql_server_name == local.mssql_server_name
    error_message = "SQL Server name is not matching with the given variable value"
  }
}
 