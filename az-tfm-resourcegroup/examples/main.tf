module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "../"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}