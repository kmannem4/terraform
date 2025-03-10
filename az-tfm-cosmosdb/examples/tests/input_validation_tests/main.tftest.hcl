
provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}


run input_validation {
  command = plan


  // expect_failures = [
  //   var.create_mode,
  //   var.kind
  // ]
  
  // TODO: Add more unit tests
  assert {
    condition     = length([for suffix in ["d01", "q01", "t02", "p01", "i01","t01"] : suffix if can(regex(".*-${suffix}$", var.cosmos_db_account_name))]) > 0
    error_message = "Cosmos DB name did not match expected"
  }
}