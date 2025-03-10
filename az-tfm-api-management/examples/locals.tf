resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  environment_suffix    = "t01"
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
  region_abbreviation = local.us_region_abbreviations[var.location]
  resource_group_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  api_management = {
    name                     = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.environment_suffix}"
    publisher_name           = "test"
    publisher_email          = "test@test.com"
    sku_tier                 = "Premium"
    sku_capacity             = "1"
    additionallocation = [
      {
        location = "westcentralus"
      }
    ]
  }
}