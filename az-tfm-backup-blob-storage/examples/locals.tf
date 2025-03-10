resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix  = "rg"
  backup_vault_suffix    = "bv"
  backup_policy_suffix   = "bp"
  backup_instance_suffix = "bis"
  storage_account_suffix = "sa"
  environment_suffix     = "t01"
  us_region_abbreviations = {
    centralus      = "cus"
    eastus         = "eus"
    eastus2        = "eus2"
    westus         = "wus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westcentralus  = "wcus"
    westus2        = "wus2"
  }
  region_abbreviation               = local.us_region_abbreviations[var.location]
  resource_group_name               = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  backup_vault_name                 = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_vault_suffix}-${local.environment_suffix}"
  backup_policy_name                = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_policy_suffix}-${local.environment_suffix}"
  backup_instance_blob_storage_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_instance_suffix}-${local.environment_suffix}"
  storage_account_name              = "co${local.region_abbreviation}tfm${random_string.resource_name.result}${local.storage_account_suffix}${local.environment_suffix}"
  containers_list                   = [for container in var.containers_list : container.name]
}
