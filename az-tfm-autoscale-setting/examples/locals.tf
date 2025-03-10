# Generate a random string with a length of 5 characters
# consisting of lowercase letters and numbers.
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Define local variables.
locals {
  # Suffixes for resource names.
  resource_group_suffix     = "rg"
  servicebus_suffix         = "svcb"
  signalr_suffix            = "signalr"
  autoscale_setting_suffix  = "scale"
  environment_suffix        = "t01"

  # Mapping of US region names to abbreviations.
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

  # Get the region abbreviation based on the provided location.
  region_abbreviation = local.us_region_abbreviations[var.location]

  # Construct resource names using the region abbreviation and suffixes.
  resource_group_name    = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  signalr_name           = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.signalr_suffix}-${local.environment_suffix}"
  servicebus_name        = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.servicebus_suffix}-${local.environment_suffix}"
  servicebus_autoscale_setting_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.servicebus_suffix}-${local.autoscale_setting_suffix}-${local.environment_suffix}"
  signalr_autoscale_setting_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.signalr_suffix}-${local.autoscale_setting_suffix}-${local.environment_suffix}"
}
