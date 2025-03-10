module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

#SEARCH SERVICE
module "search_service" {
  depends_on                                              = [module.rg]
  source                                                  = "../"
  resource_group_name                                     = local.resource_group_name
  search_service_name                                     = var.search_service_name
  location                                                = var.location
  search_service_sku                                      = var.search_service_sku
  search_service_replica_count                            = var.search_service_replica_count
  search_service_partition_count                          = var.search_service_partition_count
  search_service_authentication_failure_mode              = var.search_service_authentication_failure_mode
  search_service_customer_managed_key_enforcement_enabled = var.search_service_customer_managed_key_enforcement_enabled
  search_service_local_authentication_enabled             = var.search_service_local_authentication_enabled
  search_service_hosting_mode                             = var.search_service_hosting_mode
  search_service_public_network_access_enabled            = var.search_service_public_network_access_enabled
  search_service_identity                                 = var.search_service_identity
  search_service_allowed_ips                              = var.search_service_allowed_ips
  tags                                                    = var.tags

}
