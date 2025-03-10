module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "storage" {
  depends_on = [module.rg]
  source     = "../"
  #version = "1.0.0"
  resource_group_name                  = local.resource_group_name
  location                             = var.location
  storage_account_name                 = var.storage_account_name
  skuname                              = var.skuname
  account_kind                         = var.account_kind
  container_soft_delete_retention_days = var.container_soft_delete_retention_days
  blob_soft_delete_retention_days      = var.blob_soft_delete_retention_days
  public_network_access_enabled        = var.public_network_access_enabled
  containers_list                      = var.containers_list
  tags                                 = var.tags
}

