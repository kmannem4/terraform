<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage search service in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
# SEARCH SERVICE RESOURCE BLOCK
resource "azurerm_search_service" "search_service" {
  #checkov:skip=CKV_AZURE_210: "Ensure Azure Cognitive Search service allowed IPS does not give public Access"
  #checkov:skip=CKV_AZURE_124: "Ensure that Azure Cognitive Search disables public network access"
  name                                     = var.search_service_name
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  sku                                      = var.search_service_sku
  replica_count                            = var.search_service_replica_count
  partition_count                          = var.search_service_partition_count
  public_network_access_enabled            = var.search_service_public_network_access_enabled
  allowed_ips                              = var.search_service_allowed_ips
  authentication_failure_mode              = var.search_service_authentication_failure_mode
  customer_managed_key_enforcement_enabled = var.search_service_customer_managed_key_enforcement_enabled
  local_authentication_enabled             = var.search_service_local_authentication_enabled
  hosting_mode                             = var.search_service_hosting_mode
  tags                                     = var.tags

  dynamic "identity" {
    for_each = var.search_service_identity != null ? [1] : []
    content {
      type = var.search_service_identity
    }
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_search_service_allowed_ips"></a> [search\_service\_allowed\_ips](#input\_search\_service\_allowed\_ips) | n/a | `list(string)` | `[]` | no |
| <a name="input_search_service_authentication_failure_mode"></a> [search\_service\_authentication\_failure\_mode](#input\_search\_service\_authentication\_failure\_mode) | n/a | `string` | `null` | no |
| <a name="input_search_service_customer_managed_key_enforcement_enabled"></a> [search\_service\_customer\_managed\_key\_enforcement\_enabled](#input\_search\_service\_customer\_managed\_key\_enforcement\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_search_service_hosting_mode"></a> [search\_service\_hosting\_mode](#input\_search\_service\_hosting\_mode) | n/a | `string` | `"default"` | no |
| <a name="input_search_service_identity"></a> [search\_service\_identity](#input\_search\_service\_identity) | n/a | `string` | `"SystemAssigned"` | no |
| <a name="input_search_service_local_authentication_enabled"></a> [search\_service\_local\_authentication\_enabled](#input\_search\_service\_local\_authentication\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_search_service_name"></a> [search\_service\_name](#input\_search\_service\_name) | SEARCH SERVICE VARIABLES | `string` | n/a | yes |
| <a name="input_search_service_partition_count"></a> [search\_service\_partition\_count](#input\_search\_service\_partition\_count) | n/a | `string` | `"1"` | no |
| <a name="input_search_service_public_network_access_enabled"></a> [search\_service\_public\_network\_access\_enabled](#input\_search\_service\_public\_network\_access\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_search_service_replica_count"></a> [search\_service\_replica\_count](#input\_search\_service\_replica\_count) | n/a | `string` | `"1"` | no |
| <a name="input_search_service_sku"></a> [search\_service\_sku](#input\_search\_service\_sku) | n/a | `string` | `"standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br>  "application": "Infrastructure",<br>  "charge-to": "101-71200-5000-9500",<br>  "environment": "dev",<br>  "managed-by": "",<br>  "product": "Infrastructure"<br>}</pre> | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_search_service_authentication_failure_mode"></a> [search\_service\_authentication\_failure\_mode](#output\_search\_service\_authentication\_failure\_mode) | n/a |
| <a name="output_search_service_customer_managed_key_enforcement_enabled"></a> [search\_service\_customer\_managed\_key\_enforcement\_enabled](#output\_search\_service\_customer\_managed\_key\_enforcement\_enabled) | n/a |
| <a name="output_search_service_hosting_mode"></a> [search\_service\_hosting\_mode](#output\_search\_service\_hosting\_mode) | n/a |
| <a name="output_search_service_id"></a> [search\_service\_id](#output\_search\_service\_id) | SEARCH SERVICE OUTPUT VALUE |
| <a name="output_search_service_identity"></a> [search\_service\_identity](#output\_search\_service\_identity) | n/a |
| <a name="output_search_service_local_authentication_enabled"></a> [search\_service\_local\_authentication\_enabled](#output\_search\_service\_local\_authentication\_enabled) | n/a |
| <a name="output_search_service_name"></a> [search\_service\_name](#output\_search\_service\_name) | n/a |
| <a name="output_search_service_partition_count"></a> [search\_service\_partition\_count](#output\_search\_service\_partition\_count) | n/a |
| <a name="output_search_service_public_network_access_enabled"></a> [search\_service\_public\_network\_access\_enabled](#output\_search\_service\_public\_network\_access\_enabled) | n/a |
| <a name="output_search_service_replica_count"></a> [search\_service\_replica\_count](#output\_search\_service\_replica\_count) | n/a |
| <a name="output_search_service_sku"></a> [search\_service\_sku](#output\_search\_service\_sku) | n/a |

#### The following resources are created by this module:


- resource.azurerm_search_service.search_service (/usr/agent/azp/_work/1/s/amn-az-tfm-search-service/main.tf#2)


## Example Scenario

Create search service <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create search service

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
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

#SEARCH SERVICE
module "search_service" {
  depends_on                                              = [module.rg]
  source                                                  = "../"
  resource_group_name                                     = local.resource_group_name
  search_service_name                                     = var.search_service_name
  location                                                = var.location
  search_service_sku                                      = var.search_service_sku
  search_service_replica_count                            = var.search_service_replica_count
  search_service_partition_count                          = var.search_service_partition_count
  search_service_authentication_failure_mode              = var.search_service_authentication_failure_mode
  search_service_customer_managed_key_enforcement_enabled = var.search_service_customer_managed_key_enforcement_enabled
  search_service_local_authentication_enabled             = var.search_service_local_authentication_enabled
  search_service_hosting_mode                             = var.search_service_hosting_mode
  search_service_public_network_access_enabled            = var.search_service_public_network_access_enabled
  search_service_identity                                 = var.search_service_identity
  search_service_allowed_ips                              = var.search_service_allowed_ips
  tags                                                    = var.tags

}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
search_service_name                                     = "co-wus2-tftest-acs-t01"
location                                                = "westus2"
search_service_sku                                      = "standard"
search_service_replica_count                            = "3"
search_service_partition_count                          = "1"
search_service_authentication_failure_mode              = null
search_service_customer_managed_key_enforcement_enabled = false
search_service_local_authentication_enabled             = true
search_service_hosting_mode                             = "default"
search_service_public_network_access_enabled            = true
search_service_identity                                 = "SystemAssigned"
search_service_allowed_ips                              = []
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