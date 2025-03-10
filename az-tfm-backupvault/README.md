<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage a Backup Vault Service in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
  tags                = var.tags

  dynamic "identity" {
    for_each = var.identity.identity_ids != [] ? [1] : []
    content {
      type = var.identity.type
    }
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datastore_type"></a> [datastore\_type](#input\_datastore\_type) | Specifies the type of the data store. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the resource. Changing this forces a new Load Test to be created. | `string` | `""` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "identity_ids": [],<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the backup vault should exist. Changing this forces a new backup vault to be created. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of this Load Test. Changing this forces a new Load Test to be created. | `string` | n/a | yes |
| <a name="input_redundancy"></a> [redundancy](#input\_redundancy) | Specifies the backup storage redundancy. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the name of the Resource Group within which this Load Test should exist. Changing this forces a new Load Test to be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_vault_datastore_type"></a> [backup\_vault\_datastore\_type](#output\_backup\_vault\_datastore\_type) | The datastore type of the Backup vault. |
| <a name="output_backup_vault_identity"></a> [backup\_vault\_identity](#output\_backup\_vault\_identity) | The identity of the Backup vault. |
| <a name="output_backup_vault_name"></a> [backup\_vault\_name](#output\_backup\_vault\_name) | The name of the Backup vault. |
| <a name="output_backup_vault_redundancy"></a> [backup\_vault\_redundancy](#output\_backup\_vault\_redundancy) | The redundancy of the Backup vault. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Backup Vault. |

#### The following resources are created by this module:


- resource.azurerm_data_protection_backup_vault.backup_vault (/usr/agent/azp/_work/1/s/amn-az-tfm-backupvault/main.tf#1)


## Example Scenario

Create a Backup Vault Service <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create a Backup Vault Service

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
  backup_vault_suffix   = "bv"
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
  backup_vault_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_vault_suffix}-${local.environment_suffix}"
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

module "backup_vault" {
  depends_on = [module.rg]
  source     = "../"

  name                = local.backup_vault_name
  location            = var.location
  resource_group_name = local.resource_group_name
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location        = "westus2"
datastore_type  = "VaultStore"
redundancy      = "LocallyRedundant"
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