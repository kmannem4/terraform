<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage container app environment in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_container_app_environment" "main" {
  for_each            = var.container_app_environment_vars
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  log_analytics_workspace_id                  = each.value.log_analytics_workspace_id
  mutual_tls_enabled                          = each.value.mutual_tls_enabled
  internal_load_balancer_enabled              = each.value.internal_load_balancer_enabled
  zone_redundancy_enabled                     = each.value.zone_redundancy_enabled
  infrastructure_resource_group_name          = each.value.infrastructure_resource_group_name
  infrastructure_subnet_id                    = each.value.infrastructure_subnet_id
  dapr_application_insights_connection_string = each.value.dapr_application_insights_connection_string

  dynamic "workload_profile" {
    for_each = each.value.workload_profile != null ? each.value.workload_profile : []
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environment_vars"></a> [container\_app\_environment\_vars](#input\_container\_app\_environment\_vars) | Map of Container App Environment variables | <pre>map(object({<br>    name                                        = string<br>    log_analytics_workspace_id                  = optional(string)<br>    mutual_tls_enabled                          = optional(bool)<br>    zone_redundancy_enabled                     = optional(bool)<br>    internal_load_balancer_enabled              = optional(bool)<br>    infrastructure_resource_group_name          = optional(string)<br>    infrastructure_subnet_id                    = optional(string)<br>    dapr_application_insights_connection_string = optional(string)<br>    workload_profile = optional(list(object({<br>      name                  = string<br>      workload_profile_type = string<br>      minimum_count         = number<br>      maximum_count         = number<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | The ID of the Container App Environment |
| <a name="output_container_app_environment_name"></a> [container\_app\_environment\_name](#output\_container\_app\_environment\_name) | The name of the Container App Environment |

#### The following resources are created by this module:


- resource.azurerm_container_app_environment.main (/usr/agent/azp/_work/1/s/amn-az-tfm-container-app-environment/main.tf#1)


## Example Scenario

Create container app environment <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create container app environment

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
  resource_group_suffix            = "rg"
  container_app_environment_suffix = "cae"
  environment_suffix               = "t01"
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
  region_abbreviation            = local.us_region_abbreviations[var.location]
  resource_group_name            = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  container_app_environment_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.container_app_environment_suffix}-${local.environment_suffix}"
  container_app_environment_vars = {
    "Test" = {
      name = local.container_app_environment_name
      workload_profile = [
        {
          name                  = "Consumption",
          workload_profile_type = "Consumption",
          minimum_count         = 0,
          maximum_count         = 1
        }
      ]
    }
  }
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

module "container_app_environment" {
  depends_on                     = [module.rg]
  source                         = "../"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  container_app_environment_vars = local.container_app_environment_vars
  tags                           = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location = "westus2"
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