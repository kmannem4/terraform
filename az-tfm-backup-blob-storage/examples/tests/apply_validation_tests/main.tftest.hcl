run "actual_vs_expected_test_apply" {
  command = apply

  assert {
    condition     = module.backup_vault.id != ""
    error_message = "Error: The ID of a Backup vault Service must not be null."
  }

  assert {
    condition     = module.backup_policy_blob_storage.id != ""
    error_message = "Error: The Vault ID of a Backup Policy Blob Storage must not be null."
  }
}
