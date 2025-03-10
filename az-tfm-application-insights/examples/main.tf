module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "application_insights" {
  depends_on                    = [module.rg]
  source                        = "../"
  resource_group_name           = local.resource_group_name
  application_insight_name      = var.application_insight_name
  location                      = var.location
  application_type              = var.application_type
  retention_in_days             = var.retention_in_days
  workspace_id                  = var.workspace_id
  local_authentication_disabled = var.local_authentication_disabled
  tags                          = var.tags
}