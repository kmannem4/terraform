
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "container_app_environment" {
  depends_on                     = [module.rg]
  source                         = "../"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  container_app_environment_vars = local.container_app_environment_vars
  tags                           = var.tags
}
