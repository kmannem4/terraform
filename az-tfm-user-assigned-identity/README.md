<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage user assigned identity in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = lower(var.resource_group_name)
}

resource "azurerm_resource_group" "rg" { # TODO - Refer resource group module to make it resource & pattern module
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = var.tags
}

#---------------------------------------------------------
# Manage User Assigned Identity.
#----------------------------------------------------------

resource "azurerm_user_assigned_identity" "mi" {
  location            = var.location
  name                = var.user_assigned_identity_name
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rgrp[0].name
  tags                = var.tags
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Resource group to create | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | Name of the User Assigned Identity | `string` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mi_client_id"></a> [mi\_client\_id](#output\_mi\_client\_id) | n/a |
| <a name="output_mi_id"></a> [mi\_id](#output\_mi\_id) | n/a |
| <a name="output_mi_principal_id"></a> [mi\_principal\_id](#output\_mi\_principal\_id) | n/a |
| <a name="output_mi_tenant_id"></a> [mi\_tenant\_id](#output\_mi\_tenant\_id) | n/a |
| <a name="output_mi_tenant_location"></a> [mi\_tenant\_location](#output\_mi\_tenant\_location) | n/a |
| <a name="output_mi_tenant_name"></a> [mi\_tenant\_name](#output\_mi\_tenant\_name) | n/a |
| <a name="output_mi_tenant_resource_group_name"></a> [mi\_tenant\_resource\_group\_name](#output\_mi\_tenant\_resource\_group\_name) | n/a |

#### The following resources are created by this module:


- resource.azurerm_resource_group.rg (/usr/agent/azp/_work/1/s/amn-az-tfm-user-assigned-identity/main.tf#10)
- resource.azurerm_user_assigned_identity.mi (/usr/agent/azp/_work/1/s/amn-az-tfm-user-assigned-identity/main.tf#21)
- data source.azurerm_resource_group.rgrp (/usr/agent/azp/_work/1/s/amn-az-tfm-user-assigned-identity/main.tf#5)


## Example Scenario

Create user assigned identity <br /><br /> The following steps in example to using this module:<br /> - Create user assigned identity

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix = "rg"
  managed_id_suffix     = "mgid"
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
  user_assigned_identity_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.managed_id_suffix}-${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
# Azurerm Provider configuration
provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

module "user_assigned_identity" {
  source                      = "../"
  create_resource_group       = var.create_resource_group
  resource_group_name         = local.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.user_assigned_identity_name
  tags                        = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
create_resource_group        = true
location                     = "westus2"
tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "amnone",
  product         = "AMNOne",
  amnonecomponent = "shared",
  role            = "infrastructure",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->