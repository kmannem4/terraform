module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source                  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name     = local.resource_group_name
  location                = var.location
  tags                    = var.tags
}

module "virtual_network" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [module.rg]
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-virtual-network?ref=v1.0.0"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  vnetwork_name                  = local.vnet_name
  vnet_address_space             = var.vnet_address_space
  create_network_watcher         = false
  subnets                        = var.subnets
  tags                           = var.tags
}

module "user_assigned_identity" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on = [module.rg]
  source                      = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-user-assigned-identity?ref=v1.0.0"
  resource_group_name         = module.rg.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.mgid_name
  tags                        = var.tags
}

locals {
  nodes = {
    for i in range(2) : "worker${i}" => {
      name                  = substr("worker${i}${random_id.prefix.hex}", 0, 8)
      vm_size               = "Standard_B4ls_v2"
      node_count            = 1
      vnet_subnet_id        = module.virtual_network.subnet_ids[0]
      create_before_destroy = i % 2 == 0
      tags                  = var.tags
    }
  }
}

module "aks" {

  #checkov:skip=CKV_AZURE_168: "Ensure Azure Kubernetes Cluster (AKS) nodes should use a minimum number of 50 pods."
  #checkov:skip=CKV_AZURE_115: "Ensure that AKS enables private clusters"
  #checkov:skip=CKV2_AZURE_29: "Ensure AKS cluster has Azure CNI networking enabled"
  #checkov:skip=CKV_AZURE_227: "Ensure that the AKS cluster encrypt temp disks, caches, and data flows between Compute and Storage resources"
  #checkov:skip=CKV_AZURE_227: "Ensure that the AKS cluster encrypt temp disks, caches, and data flows between Compute and Storage resources"
  #checkov:skip=CKV_AZURE_5: "Ensure RBAC is enabled on AKS clusters"
  #checkov:skip=CKV_AZURE_116: "Ensure that AKS uses Azure Policies Add-on"
  #checkov:skip=CKV_AZURE_226: "Ensure ephemeral disks are used for OS disks"
  #checkov:skip=CKV_AZURE_232: "Ensure that only critical system pods run on system nodes"
  depends_on = [module.virtual_network, module.user_assigned_identity, module.rg]
  source = "../"

  prefix                            = "prefix-${random_id.prefix.hex}"
  kubernetes_version                = var.kubernetes_version
  resource_group_name               = local.resource_group_name
  cluster_name                      = local.aks_name
  os_disk_size_gb                   = 30
  network_plugin                    = var.network_plugin
  network_policy                    = var.network_policy
  network_plugin_mode               = var.network_plugin_mode
  sku_tier                          = "Standard"
  identity_type                     = "UserAssigned"
  identity_ids                      = [module.user_assigned_identity.mi_id]
  rbac_aad                          = false
  // role_based_access_control_enabled = true
  log_analytics_workspace_enabled   = true
  microsoft_defender_enabled        = false
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  vnet_subnet_id                    = module.virtual_network.subnet_ids[0]
  node_pools                        = local.nodes
  log_analytics_workspace_id        = var.log_analytics_workspace_id
  tags                              = var.tags
}