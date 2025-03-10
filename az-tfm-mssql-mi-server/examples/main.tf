# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "mssql_mi_server" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  location            = var.location
  managed_instance    = local.managed_instance
  tags                = var.tags
}

