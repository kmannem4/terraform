
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "container_registry" {
  depends_on                              = [module.rg]
  source                                  = "../"
  resource_group_name                     = local.resource_group_name
  container_registry_name                 = var.container_registry_name
  location                                = var.location
  sku_name                                = var.sku_name
  admin_enabled                           = var.admin_enabled
  georeplications_location                = var.georeplications_location
  zone_redundancy_enabled                 = var.zone_redundancy_enabled
  georeplications_zone_redundancy_enabled = var.georeplications_zone_redundancy_enabled
  public_network_access_enabled           = var.public_network_access_enabled
  default_action                          = var.default_action
  ip_range                                = var.ip_range
  action                                  = var.action
  tags                                    = var.tags
}


