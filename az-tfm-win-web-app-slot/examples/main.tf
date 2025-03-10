

# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "app_service_plan" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
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
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
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
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
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
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_AZURE_14: "Ensure web app redirects all HTTP traffic to HTTPS in Azure App Service"
  #checkov:skip=CKV_AZURE_78: "Ensure FTP deployments are disabled"
  #checkov:skip=CKV_AZURE_13: "Ensure App Service Authentication is set on Azure App Service"
  #checkov:skip=CKV_AZURE_17: "Ensure the web app has ‘Client Certificates (Incoming client certificates)’ set to 'On'"
  #checkov:skip=CKV_AZURE_65: "Ensure that App service enables detailed error messages"
  #checkov:skip=CKV_AZURE_214: "The web app is not using a custom domain name"
  #checkov:skip=CKV_AZURE_66: "Ensure that App service enables failed request tracing"
  #checkov:skip=CKV_AZURE_222: "Ensure that Azure Web App public network access is disabled"
  #checkov:skip=CKV_AZURE_63: "Ensure that App service enables HTTP logging"
  #checkov:skip=CKV_AZURE_15: "Ensure web app is using the latest version of TLS encryption"
  #checkov:skip=CKV_AZURE_18: "Ensure that ‘HTTP Version’ is the latest if used to run the web app"
  #checkov:skip=CKV_AZURE_88: "Ensure that app services use Azure Files"
  #checkov:skip=CKV_AZURE_213: "Ensure that App Service configures health check"
  #checkov:skip=CKV_AZURE_153: "Ensure web app redirects all HTTP traffic to HTTPS in Azure App Service Slot"	
  depends_on           = [module.app_service_plan, module.key_vault, module.virtual_network]
  source               = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-win-web-app?ref=v1.0.1"
  web_app_service_vars = local.web_app_service_vars
  location             = var.location
  resource_group_name  = local.resource_group_name
  tags                 = var.tags
}

module "web_app_slot" {
  #checkov:skip=CKV_AZURE_153: "Ensure web app redirects all HTTP traffic to HTTPS in Azure App Service Slot"
  depends_on                 = [module.app_service_plan, module.key_vault, module.virtual_network, module.web_app_service]
  source                     = "../"
  resource_group_name        = local.resource_group_name
  web_slot_vars              = local.web_slot_vars
}
