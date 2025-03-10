module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "backup_vault" {
  depends_on          = [module.rg]
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-backupvault?ref=v1.0.1"
  name                = local.backup_vault_name
  location            = var.location
  resource_group_name = local.resource_group_name
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
  identity            = var.identity
}

module "storage" {
  depends_on = [module.rg]
  source     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-storage-account?ref=v1.0.0"
  #version = "1.0.0"
  resource_group_name                  = local.resource_group_name
  location                             = var.location
  storage_account_name                 = local.storage_account_name
  skuname                              = var.skuname
  account_kind                         = var.account_kind
  container_soft_delete_retention_days = var.container_soft_delete_retention_days
  blob_soft_delete_retention_days      = var.blob_soft_delete_retention_days
  public_network_access_enabled        = var.public_network_access_enabled
  containers_list                      = var.containers_list
  tags                                 = var.tags
}

module "role_assignments" {
  depends_on = [module.rg, module.storage, module.backup_vault]
  source     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-role-assignment?ref=v1.0.0"

  system_assigned_managed_identities_by_principal_id = {
    mi1 = module.backup_vault.backup_vault_identity[0].principal_id
  }
  role_definitions = {
    role1 = var.role_definition_name
  }
  role_assignments_for_scopes = {
    example1 = {
      scope = module.storage.storage_account_id
      role_assignments = {
        role_assignment_1 = {
          role_definition                    = "role1"
          system_assigned_managed_identities = ["mi1"]
        }
      }
    }
  }
}

module "backup_policy_blob_storage" {
  depends_on                             = [module.rg, module.backup_vault, module.storage, module.role_assignments]
  source                                 = "../"
  backup_policy_blob_storage_name        = local.backup_policy_name
  vault_id                               = module.backup_vault.id
  backup_repeating_time_intervals        = var.backup_repeating_time_intervals
  operational_default_retention_duration = var.operational_default_retention_duration
  vault_default_retention_duration       = var.vault_default_retention_duration
  time_zone                              = var.time_zone
  retention_rule                         = var.retention_rule
  location                               = var.location
  storage_account_id                     = module.storage.storage_account_id
  storage_account_container_names        = local.containers_list
  backup_instance_blob_storage_name      = local.backup_instance_blob_storage_name
}
