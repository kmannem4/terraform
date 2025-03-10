# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}
module "ag" {
  depends_on          = [module.rg]
  source              = "../"
  action_group        = var.action_group
  resource_group_name = local.resource_group_name
  location            = var.location
}
