module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = module.rg.resource_group_name
  location            = var.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "snet" {
  #checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  name                 = local.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.0.0/24"]
}

module "user_assigned_identity" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                  = [module.rg]
  source                      = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-user-assigned-identity?ref=v1.0.0"
  create_resource_group       = false
  resource_group_name         = local.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.user_assigned_identity_name
  tags                        = var.tags
}

module "application-gateway" {
  #checkov:skip=CKV_AZURE_218: "Ensure Application Gateway defines secure protocols for in transit communication"
  depends_on                     = [azurerm_subnet.snet, module.rg, module.user_assigned_identity]
  source                         = "../"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  virtual_network_name           = local.vnet_name
  subnet_name                    = local.subnet_name
  enable_http2                   = true
  app_gateway_name               = local.app_gateway_name
  public_ip_name                 = local.public_ip_name
  sku                            = var.sku
  backend_address_pools          = var.backend_address_pools
  frontend_port_name             = local.frontend_port_name
  gateway_ip_configuration_name  = local.gateway_ip_configuration_name
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  backend_http_settings          = var.backend_http_settings
  http_listeners                 = var.http_listeners
  request_routing_rules          = var.request_routing_rules
  identity_ids                   = ["${module.user_assigned_identity.mi_id}"]
  tags                           = var.tags
}
