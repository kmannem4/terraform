resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric  = true
}

locals {
  resource_group_suffix = "rg"
  signalr_suffix        = "signalr"
  environment_suffix    = "t01"
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
  signalr_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.signalr_suffix}-${local.environment_suffix}"
}