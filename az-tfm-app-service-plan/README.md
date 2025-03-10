<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage app service plan in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#---------------------------------
# Local declarations
#---------------------------------

// locals {
//   resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
//   location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
// }

#data "azurerm_log_analytics_workspace" "logws" {
#  count               = var.log_analytics_workspace_name != null ? 1 : 0
#  name                = var.log_analytics_workspace_name
#  resource_group_name = local.resource_group_name
#}

#-------------------------------------------------
# App Service Plan Creation - Default is "true"
#-------------------------------------------------

resource "azurerm_service_plan" "asp" {
  count                        = var.create_app_service_plan ? 1 : 0
  name                         = var.app_service_plan_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  os_type                      = var.os_type
  sku_name                     = var.sku_name
  zone_balancing_enabled       = var.zone_balancing_enabled
  worker_count                 = var.sku_name == "Y1" ? null : var.worker_count
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  app_service_environment_id   = var.app_service_environment_id
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  #tags                         = merge({ "ResourceName" = format("%s", var.app_service_plan_name) }, var.tags, )
  tags = var.tags
}

#---------------------------------------------------------------
# azurerm monitoring diagnostics for App Service Plan
#---------------------------------------------------------------

# resource "azurerm_monitor_diagnostic_setting" "asp-diag" {
#   depends_on                 = [azurerm_service_plan.asp]
#   count                      = var.log_analytics_workspace_id != null && var.create_app_service_plan ? 1 : 0
#   name                       = lower("asp-${var.app_service_plan_name}-diag")
#   target_resource_id         = azurerm_service_plan.asp[count.index].id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }
# Module to create a diagnostic setting
module "diagnostic" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [azurerm_service_plan.asp]                                                                                         # The diagnostic setting depends on the resource group
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-diagnostic-setting?ref=v1.0.0" # Source for the diagnostic setting module
  count                          = var.log_analytics_workspace_id != null && var.create_app_service_plan ? 1 : 0
  diag_name                      = lower("asp-${var.app_service_plan_name}-diag") # Name of the diagnostic setting
  resource_id                    = azurerm_service_plan.asp[count.index].id       # Resource ID to monitor
  log_analytics_workspace_id     = var.log_analytics_workspace_id                 # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                                    # Type of Log Analytics destination
  logs_destinations_ids = [
    var.log_analytics_workspace_id # Log Analytics workspace ID
  ]
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_environment_id"></a> [app\_service\_environment\_id](#input\_app\_service\_environment\_id) | The ID of the App Service Environment to create this Service Plan in. Requires an Isolated SKU. Use one of I1, I2, I3 for azurerm\_app\_service\_environment, or I1v2, I2v2, I3v2 for azurerm\_app\_service\_environment\_v3 | `string` | `null` | no |
| <a name="input_app_service_plan_name"></a> [app\_service\_plan\_name](#input\_app\_service\_plan\_name) | App Serice Plan name | `string` | n/a | yes |
| <a name="input_create_app_service_plan"></a> [create\_app\_service\_plan](#input\_create\_app\_service\_plan) | App Service Plan to create | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Resource group to create | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | log analytics workspace id | `string` | `null` | no |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU. | `number` | `null` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The O/S type for the App Services to be hosted in this plan. Possible values include `Windows`, `Linux`, and `WindowsContainer`. | `string` | n/a | yes |
| <a name="input_per_site_scaling_enabled"></a> [per\_site\_scaling\_enabled](#input\_per\_site\_scaling\_enabled) | Should Per Site Scaling be enabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU for the plan. Possible values include B1, B2, B3, D1, F1, FREE, I1, I2, I3, I1v2, I2v2, I3v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, S1, S2, S3, SHARED, Y1, EP1, EP2, EP3, WS1, WS2, and WS3. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | The number of Workers (instances) to be allocated. | `number` | `1` | no |
| <a name="input_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#input\_zone\_balancing\_enabled) | Should the Service Plan balance across Availability Zones in the region. | `bool` | `false` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | The O/S type for the App Services to be hosted in this plan |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | ID of the created Service Plan |
| <a name="output_service_plan_location"></a> [service\_plan\_location](#output\_service\_plan\_location) | Azure location of the created Service Plan |
| <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name) | Name of the created Service Plan |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU for the plan |

#### The following resources are created by this module:


- resource.azurerm_service_plan.asp (/usr/agent/azp/_work/1/s/amn-az-tfm-app-service-plan/main.tf#20)


## Example Scenario

Create app service plan <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create app service plan

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

module "app_service_plan" {
  depends_on                 = [module.rg]
  source                     = "../"
  resource_group_name        = local.resource_group_name
  create_app_service_plan    = var.create_app_service_plan
  location                   = var.location
  os_type                    = var.os_type
  sku_name                   = var.sku_name
  app_service_plan_name      = var.app_service_plan_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
create_app_service_plan    = true
location                   = "westus2"
app_service_plan_name      = "amn-wus2-tftest-aspl-t01"
os_type                    = "Linux"
sku_name                   = "P1v2"
log_analytics_workspace_id = null
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