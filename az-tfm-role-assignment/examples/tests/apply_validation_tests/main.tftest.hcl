provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run actual_vs_expected_test_apply {
  command = apply
  assert {
    condition     = { for idx, key in keys(module.role_assignments.role_defintions) : (idx + 1) => { value = true } } == { for key, v in local.role_assignments : key => { value = strcontains(v.value, local.role_defintions[key].value) } }
    error_message = "Role Assignment is not matching with given Role defintions Role Assignment"
  }

    assert {
    condition     = { for k, v in module.role_assignments.all_principals : k => { value = v.principal_id } } == { for k, v in module.role_assignments.user_assigned_managed_identities : k => { value = v } }
    error_message = "Role Assignment managed identity is not matching with given assigned role"
  }

}
