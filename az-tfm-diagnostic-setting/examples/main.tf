# Module to create a resource group
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0" # Source for the resource group module
  resource_group_name = local.resource_group_name                                                                          # Name of the resource group
  location            = var.location                                                                                       # Location of the resource group
  tags                = var.tags                                                                                           # Tags to assign to the resource group
}

# Module to create a storage account
module "storage" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  #checkov:skip=CKV_AZURE_244: "Avoid the use of local users for Azure Storage unless necessary"
  depends_on           = [module.rg]                                                                                          # The storage account depends on the resource group
  source               = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-storage-account?ref=v1.0.0" # Source for the storage account module
  resource_group_name  = local.resource_group_name                                                                            # Name of the resource group
  location             = var.location                                                                                         # Location of the storage account
  storage_account_name = local.storage_account_name                                                                           # Name of the storage account
  containers_list      = var.containers_list                                                                                  # List of containers to create
  tags                 = var.tags                                                                                             # Tags to assign to the storage account
}

# Module to create a diagnostic setting
module "diagnostic" {
  depends_on = [module.rg] # The diagnostic setting depends on the resource group
  source     = "../"       # Source for the diagnostic setting module

  diag_name                      = local.diag_name                   # Name of the diagnostic setting
  resource_id                    = module.storage.storage_account_id # Resource ID to monitor
  log_analytics_workspace_id     = var.log_analytics_workspace_id    # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                       # Type of Log Analytics destination
  logs_destinations_ids = [
    var.log_analytics_workspace_id # Log Analytics workspace ID
  ]
}
