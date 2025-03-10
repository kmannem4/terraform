<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage logic app workflow in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl

resource "azurerm_logic_app_workflow" "main" {
  for_each            = var.logic_app_vars
  name                = each.value.name
  tags                = var.tags
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "identity" {
    for_each = each.value.identity == null ? [] : [each.value.identity]
    content {
      type         = identity.value.identity_ids == null ? "SystemAssigned" : "UserAssigned"
      identity_ids = identity.value.identity_ids
    }
  }

  integration_service_environment_id = each.value.integration_service_environment_id
  logic_app_integration_account_id   = each.value.logic_app_integration_account_id
  enabled                            = each.value.enabled
  workflow_parameters                = each.value.workflow_parameters
  parameters                         = each.value.parameters
  workflow_schema                    = each.value.workflow_schema
  workflow_version                   = each.value.workflow_version

}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group. | `string` | n/a | yes |
| <a name="input_logic_app_vars"></a> [logic\_app\_vars](#input\_logic\_app\_vars) | A mapping of logic app variables to assign to the resource | <pre>map(object({<br>    name = string<br>    identity = optional(object({<br>      identity_ids = optional(list(string))<br>    }))<br>    integration_service_environment_id = optional(string)<br>    logic_app_integration_account_id   = optional(string)<br>    enabled                            = optional(bool)<br>    workflow_parameters                = optional(map(any))<br>    parameters                         = optional(map(any))<br>    workflow_schema                    = optional(string)<br>    workflow_version                   = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connector_endpoint_ip_addresses"></a> [connector\_endpoint\_ip\_addresses](#output\_connector\_endpoint\_ip\_addresses) | value of connector\_endpoint\_ip\_addresses |
| <a name="output_connector_outbound_ip_addresses"></a> [connector\_outbound\_ip\_addresses](#output\_connector\_outbound\_ip\_addresses) | value of connector\_outbound\_ip\_addresses |
| <a name="output_logic_app_endpoint"></a> [logic\_app\_endpoint](#output\_logic\_app\_endpoint) | value of logic\_app\_endpoint |
| <a name="output_logic_app_identity"></a> [logic\_app\_identity](#output\_logic\_app\_identity) | The principal ID of the assigned identity for the Logic App Workflow. |
| <a name="output_logic_app_workflow_id"></a> [logic\_app\_workflow\_id](#output\_logic\_app\_workflow\_id) | value of logic\_app\_workflow\_id |
| <a name="output_logic_app_workflow_name"></a> [logic\_app\_workflow\_name](#output\_logic\_app\_workflow\_name) | value of logic\_app\_workflow\_name |
| <a name="output_workflow_endpoint_ip_addresses"></a> [workflow\_endpoint\_ip\_addresses](#output\_workflow\_endpoint\_ip\_addresses) | value of workflow\_endpoint\_ip\_addresses |
| <a name="output_workflow_outbound_ip_addresses"></a> [workflow\_outbound\_ip\_addresses](#output\_workflow\_outbound\_ip\_addresses) | value of workflow\_outbound\_ip\_addresses |

#### The following resources are created by this module:


- resource.azurerm_logic_app_workflow.main (/usr/agent/azp/_work/1/s/amn-az-tfm-logic-app-workflow/main.tf#2)


## Example Scenario

Create logic app workflow <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create logic app workflow

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
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "logic_app" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
  logic_app_vars      = local.logic_app_vars
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