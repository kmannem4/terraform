run "actual_vs_expected_test_apply" {
  command = apply

  assert {
    condition     = module.backup_vault.id != ""
    error_message = "Error: The ID of a Backup vault Service must not be null."
  }

  assert {
    condition     = module.backup_vault.backup_vault_name == local.backup_vault_name
    error_message = "Error: The name of a Test should be same in both module and local."
  }
  
  assert {
    condition     = module.backup_vault.backup_vault_redundancy != ""
    error_message = "Error: The Redundancy of a Backup vault Service must not be null."
  }
  
    assert {
    condition     = module.backup_vault.backup_vault_datastore_type != ""
    error_message = "Error: The Datastore type of a Backup vault Service must not be null."
  }
}
