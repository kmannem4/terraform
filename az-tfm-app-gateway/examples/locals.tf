resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  app_gateway_suffix    = "appgw"
  vnet_suffix           = "vnet"
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
  resource_group_name            = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  vnet_name                      = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suffix}-${local.environment_suffix}"
  subnet_name                    = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-subnet"
  app_gateway_name               = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-${local.environment_suffix}"
  public_ip_name                 = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-pip"
  frontend_port_name             = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-feport"
  frontend_ip_configuration_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-feip"
  gateway_ip_configuration_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-gwipc"
  user_assigned_identity_name    = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.app_gateway_suffix}-uaid-${local.environment_suffix}"
}
