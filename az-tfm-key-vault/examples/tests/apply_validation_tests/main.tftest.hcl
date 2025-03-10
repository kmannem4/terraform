provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run app_service_plan_attribute_actual_vs_expected_test_apply {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.key_vault.key_vault_name == local.key_vault_name
    error_message = "key Vault name is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_resource_group_name == local.resource_group_name
    error_message = "key Vault RG name is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_location == var.location
    error_message = "key Vault location is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_purge_protection_enabled == var.enable_purge_protection
    error_message = "key Vault enable_purge_protection is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_soft_delete_retention_days == var.soft_delete_retention_days
    error_message = "key Vault soft_delete_retention_days is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_sku_name == var.key_vault_sku_pricing_tier
    error_message = "key Vault sku_name is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_enabled_for_template_deployment == var.enabled_for_template_deployment
    error_message = "key Vault enabled_for_template_deployment is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_enabled_for_disk_encryption == var.enabled_for_disk_encryption
    error_message = "key Vault enabled_for_disk_encryption is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_enable_rbac_authorization == var.enable_rbac_authorization
    error_message = "key Vault enable_rbac_authorization is not matching with given variable value"
  }
  assert {
    condition     = module.key_vault.key_vault_enabled_for_deployment == var.enabled_for_deployment
    error_message = "key Vault enabled_for_deployment is not matching with given variable value"
  }

  assert {
    condition     = module.key_vault.key_vault_public_network_access_enabled == var.public_network_access_enabled
    error_message = "key Vault public_network_access_enabled is not matching with given variable value"
  }
}
