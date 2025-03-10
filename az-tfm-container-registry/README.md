<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage container registry in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_container_registry" "acr" {
  #checkov:skip=CKV_AZURE_164: skip
  #checkov:skip=CKV_AZURE_167: skip
  #checkov:skip=CKV_AZURE_165: skip
  #checkov:skip=CKV_AZURE_166: skip
  #checkov:skip=CKV_AZURE_163: skip
  #checkov:skip=CKV_AZURE_138: skip
  #checkov:skip=CKV_AZURE_233: skip
  #checkov:skip=CKV_AZURE_237: skip
  name                          = var.container_registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku_name
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  georeplications {
    location                = var.georeplications_location
    zone_redundancy_enabled = var.georeplications_zone_redundancy_enabled
  }
  network_rule_set {
    default_action = var.default_action
    ip_rule {
      action   = var.action
      ip_range = var.ip_range
    }
  }
  tags = var.tags
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The action for the container registry. | `string` | n/a | yes |
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | admin enabled | `bool` | n/a | yes |
| <a name="input_container_registry_name"></a> [container\_registry\_name](#input\_container\_registry\_name) | container registry name | `string` | n/a | yes |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | The default action for the container registry. | `string` | n/a | yes |
| <a name="input_georeplications_location"></a> [georeplications\_location](#input\_georeplications\_location) | The georeplications location for the container registry. | `string` | n/a | yes |
| <a name="input_georeplications_zone_redundancy_enabled"></a> [georeplications\_zone\_redundancy\_enabled](#input\_georeplications\_zone\_redundancy\_enabled) | The georeplications zone redundancy enabled for the container registry. | `bool` | n/a | yes |
| <a name="input_ip_range"></a> [ip\_range](#input\_ip\_range) | The ip range for the container registry. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location. | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | The public network access enabled for the container registry. | `bool` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU for the container registry. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | The zone redundancy enabled for the container registry. | `bool` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_enabled"></a> [admin\_enabled](#output\_admin\_enabled) | The admin enabled for the container registry |
| <a name="output_container_registry_id"></a> [container\_registry\_id](#output\_container\_registry\_id) | ID of the created container registry ID |
| <a name="output_container_registry_name"></a> [container\_registry\_name](#output\_container\_registry\_name) | Name of the created Service container registry |
| <a name="output_location"></a> [location](#output\_location) | Azure location of the created Service container registry |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | The public network access enabled for the container registry |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU for the container registry |
| <a name="output_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#output\_zone\_redundancy\_enabled) | The zone redundancy enabled for the container registry |

#### The following resources are created by this module:


- resource.azurerm_container_registry.acr (/usr/agent/azp/_work/1/s/amn-az-tfm-container-registry/main.tf#1)


## Example Scenario

Create container registry <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create container registry

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
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl

module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "container_registry" {
  depends_on                              = [module.rg]
  source                                  = "../"
  resource_group_name                     = local.resource_group_name
  container_registry_name                 = var.container_registry_name
  location                                = var.location
  sku_name                                = var.sku_name
  admin_enabled                           = var.admin_enabled
  georeplications_location                = var.georeplications_location
  zone_redundancy_enabled                 = var.zone_redundancy_enabled
  georeplications_zone_redundancy_enabled = var.georeplications_zone_redundancy_enabled
  public_network_access_enabled           = var.public_network_access_enabled
  default_action                          = var.default_action
  ip_range                                = var.ip_range
  action                                  = var.action
  tags                                    = var.tags
}


``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location                                = "westus2"
container_registry_name                 = "cowus2tftestacrt01"
sku_name                                = "Premium"
admin_enabled                           = true
georeplications_location                = "west US 3"
georeplications_zone_redundancy_enabled = false
zone_redundancy_enabled                 = true
public_network_access_enabled           = true
default_action                          = "Allow"
action                                  = "Allow"
ip_range                                = "119.235.50.186"
tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "Platform Services",
  product         = "Platform Services",
  amnonecomponent = "shared",
  role            = "infrastructure-tf-unit-test",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->