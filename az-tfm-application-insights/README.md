<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage application insights in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_application_insights" "application_insights" {
  name                          = var.application_insight_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  application_type              = var.application_type
  retention_in_days             = var.retention_in_days
  workspace_id                  = var.workspace_id
  local_authentication_disabled = var.local_authentication_disabled
  tags                          = var.tags
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insight_name"></a> [application\_insight\_name](#input\_application\_insight\_name) | The name of the Application Insights resource. | `string` | n/a | yes |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | The type of the Application Insights web or app. | `string` | `"web"` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | local authentication disabled | `bool` | `"false"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Application Insights should be created. | `string` | `"westus2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Azure Resource Group. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | retention in days | `number` | `30` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Any tags that should be present on the application insights resources | `map(string)` | `{}` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | log analytics workspace | `string` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_insights_id"></a> [app\_insights\_id](#output\_app\_insights\_id) | Application insights ID OUTPUT VALUE |
| <a name="output_application_insight_name"></a> [application\_insight\_name](#output\_application\_insight\_name) | n/a |
| <a name="output_application_type"></a> [application\_type](#output\_application\_type) | n/a |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | n/a |
| <a name="output_local_authentication_disabled"></a> [local\_authentication\_disabled](#output\_local\_authentication\_disabled) | n/a |
| <a name="output_location"></a> [location](#output\_location) | n/a |
| <a name="output_retention_in_days"></a> [retention\_in\_days](#output\_retention\_in\_days) | n/a |

#### The following resources are created by this module:


- resource.azurerm_application_insights.application_insights (/usr/agent/azp/_work/1/s/amn-az-tfm-application-insights/main.tf#1)


## Example Scenario

Create application insights <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create application insights

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

module "application_insights" {
  depends_on                    = [module.rg]
  source                        = "../"
  resource_group_name           = local.resource_group_name
  application_insight_name      = var.application_insight_name
  location                      = var.location
  application_type              = var.application_type
  retention_in_days             = var.retention_in_days
  workspace_id                  = var.workspace_id
  local_authentication_disabled = var.local_authentication_disabled
  tags                          = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location                      = "westus2"
application_insight_name      = "co-wus2-tftest-ai-t01"
application_type              = "web"
retention_in_days             = 30
workspace_id                  = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"
local_authentication_disabled = true
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