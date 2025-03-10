// provider "azurerm" {
//   subscription_id = var.subscription_id
//   features {}
// }

run "actual_vs_expected_test_apply" {
  command = apply

  assert {
    condition     = module.load_test.id != ""
    error_message = "Error: The ID of a Load Test Service must not be null."
  }

  assert {
    condition     = module.load_test.data_plane_uri != ""
    error_message = "Error: The data_plane_uri of a Load Test Service must not be null."
  }

  assert {
    condition     = module.load_test.test_name == local.load_test_name
    error_message = "Error: The name of a Test should be same in both module and local."
  }


  assert {
    condition     = module.load_test.test_location == var.location
    error_message = "Error: The location of a Test must not be null."
  }

  assert {
    condition     = module.load_test.test_encryption != ""
    error_message = "Error: The encryption of a Test must not be null."
  }

  assert {
    condition     = module.load_test.description != ""
    error_message = "Error: The description of a Load Test Service must not be null."
  }
  
}
