<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage a Load Test Service in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_load_test" "load_test" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name

  # Conditionally include description if not empty
  description = var.description != "" ? var.description : null

  dynamic "identity" {
   for_each = var.identity.identity_ids != [] ? [1] : []
   content {
     type         = var.identity.type
     identity_ids = var.identity.identity_ids
   }
  }

  dynamic "encryption" {
   for_each = var.customer_managed_key_url != "" ? [1] : []
   content {
      identity {
        type = var.identity.type
        identity_id = var.identity.identity_ids
        // dynamic "identity_id" {
        //   for_each = var.identity.type == "UserAssigned" ? [1] : []
        //   content  {
        //     identity_id = var.identity.identity_ids
        //   }
        // }
      }

      key_url = var.customer_managed_key_url
    }
  }

  tags = var.tags
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_customer_managed_key_url"></a> [customer\_managed\_key\_url](#input\_customer\_managed\_key\_url) | The URI specifying the Key vault and key to be used to encrypt data in this resource. The URI should include the key version. Changing this forces a new Load Test to be created. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the resource. Changing this forces a new Load Test to be created. | `string` | `""` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "identity_ids": [],<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Load Test should exist. Changing this forces a new Load Test to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of this Load Test. Changing this forces a new Load Test to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the name of the Resource Group within which this Load Test should exist. Changing this forces a new Load Test to be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_plane_uri"></a> [data\_plane\_uri](#output\_data\_plane\_uri) | Resource data plane URI. |
| <a name="output_description"></a> [description](#output\_description) | The description of the Load Test. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Load Test. |
| <a name="output_test_encryption"></a> [test\_encryption](#output\_test\_encryption) | The encryption of the Test. |
| <a name="output_test_location"></a> [test\_location](#output\_test\_location) | The location of the Test. |
| <a name="output_test_name"></a> [test\_name](#output\_test\_name) | The name of the Test. |

#### The following resources are created by this module:


- resource.azurerm_load_test.load_test (/usr/agent/azp/_work/1/s/amn-az-tfm-load-test/main.tf#1)


## Example Scenario

Create a Load Test Service <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create a Load Test Service

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric  = true
}

locals {
  resource_group_suffix = "rg"
  load_test_suffix        = "lt"
  environment_suffix    = "t01"
  us_region_abbreviations = {
    centralus       = "cus"
    eastus          = "eus"
    eastus2         = "eus2"
    westus          = "wus"
    northcentralus  = "ncus"
    southcentralus  = "scus"
    westcentralus   = "wcus"
    westus2         = "wus2"
  }
  region_abbreviation = local.us_region_abbreviations[var.location]
  resource_group_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  load_test_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.load_test_suffix}-${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source                  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name     = local.resource_group_name
  location                = var.location
  tags                    = var.tags
}

module "load_test" {
  depends_on = [module.rg]
  source  = "../"

  name                = local.load_test_name
  location            = var.location
  resource_group_name = local.resource_group_name
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location        = "westus2"
subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
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