module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "servicebus" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on                    = [module.rg]
  source                        = "../"
  resource_group_name           = local.resource_group_name
  queue_vars                    = var.queue_vars
  topic_vars                    = var.topic_vars
  location                      = var.location
  servicebus_local_auth_enabled = var.servicebus_local_auth_enabled
  servicebus_name               = var.servicebus_name
  servicebus_location           = var.servicebus_location
  servicebus_sku_name           = var.servicebus_sku_name
  servicebus_capacity           = var.servicebus_capacity
  premium_messaging_partitions  = var.premium_messaging_partitions
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  servicebus_authorization_vars = var.servicebus_authorization_vars
  tags                          = var.tags
}
