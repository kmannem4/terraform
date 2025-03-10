module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "app_service_plan" {
  depends_on                 = [module.rg]
  source                     = "../"
  resource_group_name        = local.resource_group_name
  create_app_service_plan    = var.create_app_service_plan
  location                   = var.location
  os_type                    = var.os_type
  sku_name                   = var.sku_name
  app_service_plan_name      = var.app_service_plan_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}
