
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "container_app_environment" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [module.rg]
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-container-app-environment?ref=v1.0.0"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  container_app_environment_vars = local.container_app_environment_vars
  tags                           = var.tags
}

module "container_app" {
  depends_on                   = [module.container_app_environment]
  source                       = "../"
  resource_group_name          = local.resource_group_name
  container_app_environment_id = module.container_app_environment.container_app_environment_id["Test"]
  tags                         = var.tags
  container_apps               = local.container_apps_vars
}
