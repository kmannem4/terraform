resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  logic_app_suffix      = "la"
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
  resource_group_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  test_logic_app_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.logic_app_suffix}-${local.environment_suffix}"
  test1_logic_app_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.logic_app_suffix}-test1-${local.environment_suffix}"
  logic_app_vars = {
    "Test" = {
      name = local.test_logic_app_name
      parameters = {
        "Environment" = jsonencode(
          {
            defaultValue = "Test"
            type         = "String"
          }
        )
      }
      workflow_parameters = {
        "Environment" = jsonencode(
          {
            defaultValue = "Test"
            type         = "String"
          }
        )
      }
    }
    "Test1" = {
      name = local.test1_logic_app_name
      parameters = {
        "Environment" = jsonencode(
          {
            defaultValue = "Test1"
            type         = "String"
          }
        )
      }
      workflow_parameters = {
        "Environment" = jsonencode(
          {
            defaultValue = "Test1"
            type         = "String"
          }
        )
      }
    }
  }
}
