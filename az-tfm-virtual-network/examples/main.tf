module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}


module "virtual_network" {
  depends_on                     = [module.rg]
  source                         = "../"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  vnetwork_name                  = var.vnetwork_name
  vnet_address_space             = var.vnet_address_space
  subnets                        = var.subnets
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
