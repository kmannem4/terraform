resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  redis_suffix          = "redis"
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

  # resource_group_name   = "co-wus2-amnoneshared-rg-t02"
  resource_group_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  redis_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.redis_suffix}-${local.environment_suffix}"

  redis_vars = {
    "test-redis" = {
      name                = local.redis_name
      capacity            = 1
      family              = "C"
      sku_name            = "Basic"
      minimum_tls_version = "1.2"
      redis_configuration = {
        authentication_enabled                  = true
        active_directory_authentication_enabled = true
      }
    }
  }
}
