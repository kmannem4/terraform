# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "app_service_plan" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                 = [module.rg]
  source                     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-app-service-plan?ref=v1.0.0"
  resource_group_name        = local.resource_group_name
  create_app_service_plan    = var.create_app_service_plan
  location                   = var.location
  os_type                    = var.os_type
  sku_name                   = var.sku_name
  app_service_plan_name      = local.app_service_plan_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

module "virtual_network" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [module.rg]
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-virtual-network?ref=v1.0.0"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  vnetwork_name                  = local.vnet_name
  vnet_address_space             = var.vnet_address_space
  subnets                        = local.subnets
  gateway_subnet_address_prefix  = var.gateway_subnet_address_prefix
  firewall_subnet_address_prefix = var.firewall_subnet_address_prefix
  create_network_watcher         = var.create_network_watcher
  create_ddos_plan               = var.create_ddos_plan
  edge_zone                      = var.edge_zone
  flow_timeout_in_minutes        = var.flow_timeout_in_minutes
  dns_servers                    = var.dns_servers
  tags                           = var.tags
  ddos_plan_name                 = var.ddos_plan_name
}

module "key_vault" {
  # version = "1.0.0"
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkovLskip=CKV_AZURE_109: "Ensure that key vault allows firewall rules settings"
  depends_on                                 = [module.rg, module.virtual_network]
  source                                     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-key-vault?ref=v1.0.0"
  resource_group_name                        = local.resource_group_name
  key_vault_name                             = local.key_vault_name
  location                                   = var.location
  key_vault_sku_pricing_tier                 = var.key_vault_sku_pricing_tier
  enable_purge_protection                    = var.enable_purge_protection
  soft_delete_retention_days                 = var.soft_delete_retention_days
  self_key_permissions_access_policy         = var.self_key_permissions_access_policy
  self_secret_permissions_access_policy      = var.self_secret_permissions_access_policy
  self_certificate_permissions_access_policy = var.self_certificate_permissions_access_policy
  self_storage_permissions_access_policy     = var.self_storage_permissions_access_policy
  access_policies                            = var.access_policies
  secrets                                    = var.secrets
  enable_private_endpoint                    = var.enable_private_endpoint
  virtual_network_name                       = var.virtual_network_name
  private_subnet_address_prefix              = var.private_subnet_address_prefix
  public_network_access_enabled              = var.public_network_access_enabled
  enabled_for_template_deployment            = var.enabled_for_template_deployment
  enabled_for_disk_encryption                = var.enabled_for_disk_encryption
  enabled_for_deployment                     = var.enabled_for_deployment
  enable_rbac_authorization                  = var.enable_rbac_authorization
  tags                                       = var.tags
}

module "web_app_service" {
  #checkov:skip=CKV_AZURE_14: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_78: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_13: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_17: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_65: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_214: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_66: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_222: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_63: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_15: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_18: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_88: The web app is not using a custom domain name
  #checkov:skip=CKV_AZURE_213: The web app is not using a custom domain name
  depends_on           = [module.app_service_plan, module.key_vault, module.virtual_network]
  source               = "../"
  web_app_service_vars = local.web_app_service_vars
  location             = var.location
  resource_group_name  = local.resource_group_name
  tags                 = var.tags
}
