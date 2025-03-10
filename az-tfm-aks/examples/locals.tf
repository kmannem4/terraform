resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric  = true
}

resource "random_id" "prefix" {
  byte_length = 8
}

locals {
  resource_group_suffix = "rg"
  aks_suffix            = "aks"
  vnet_suvnetffix           = "vnet"
  environment_suffix    = "t01"
  mgid_suffix           = "mgid"
  us_region_abbreviations = {
    centralus       = "cus"
    eastus          = "eus"
    eastus2         = "eus2"
    westus          = "wus"
    northcentralus  = "ncus"
    southcentralus  = "scus"
    westcentralus   = "wcus"
    westus2         = "wus2"
  }
  region_abbreviation = local.us_region_abbreviations[var.location]
  resource_group_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  aks_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.aks_suffix}-${local.environment_suffix}"
  vnet_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suvnetffix}-${local.environment_suffix}"
  mgid_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.mgid_suffix}-${local.environment_suffix}"
}