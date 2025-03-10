<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage a Backup Blob Storage Service in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_data_protection_backup_policy_blob_storage" "data_protection_backup_policy_blob_storage" {
  name                                   = var.backup_policy_blob_storage_name
  vault_id                               = var.vault_id
  backup_repeating_time_intervals        = var.backup_repeating_time_intervals
  operational_default_retention_duration = var.operational_default_retention_duration
  vault_default_retention_duration       = var.vault_default_retention_duration
  time_zone                              = var.time_zone

  dynamic "retention_rule" {
    for_each = var.retention_rule == null ? [] : var.retention_rule
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      dynamic "criteria" {
        for_each = retention_rule.value.criteria == null ? [] : retention_rule.value.criteria
        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_month          = criteria.value.days_of_month
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }
      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle == null ? [] : retention_rule.value.life_cycle
        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_blob_storage" "data_protection_backup_instance_blob_storage" {
  depends_on = [azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage]

  name                            = var.backup_instance_blob_storage_name
  vault_id                        = var.vault_id
  location                        = var.location
  storage_account_id              = var.storage_account_id
  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage.id
  storage_account_container_names = var.storage_account_container_names
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_instance_blob_storage_name"></a> [backup\_instance\_blob\_storage\_name](#input\_backup\_instance\_blob\_storage\_name) | n/a | `string` | n/a | yes |
| <a name="input_backup_policy_blob_storage_name"></a> [backup\_policy\_blob\_storage\_name](#input\_backup\_policy\_blob\_storage\_name) | Purpose: Define the input variables for the module. | `string` | n/a | yes |
| <a name="input_backup_repeating_time_intervals"></a> [backup\_repeating\_time\_intervals](#input\_backup\_repeating\_time\_intervals) | n/a | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_operational_default_retention_duration"></a> [operational\_default\_retention\_duration](#input\_operational\_default\_retention\_duration) | n/a | `string` | n/a | yes |
| <a name="input_retention_rule"></a> [retention\_rule](#input\_retention\_rule) | n/a | <pre>list(object({<br>    name     = string<br>    priority = string<br>    criteria = list(object({<br>      absolute_criteria      = string<br>      days_of_month          = string<br>      days_of_week           = string<br>      months_of_year         = string<br>      scheduled_backup_times = string<br>      weeks_of_month         = string<br>    }))<br>    life_cycle = list(object({<br>      data_store_type = string<br>      duration        = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_storage_account_container_names"></a> [storage\_account\_container\_names](#input\_storage\_account\_container\_names) | n/a | `list(string)` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | n/a | `string` | n/a | yes |
| <a name="input_vault_default_retention_duration"></a> [vault\_default\_retention\_duration](#input\_vault\_default\_retention\_duration) | n/a | `string` | n/a | yes |
| <a name="input_vault_id"></a> [vault\_id](#input\_vault\_id) | n/a | `string` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_instance_blob_storage_name"></a> [backup\_instance\_blob\_storage\_name](#output\_backup\_instance\_blob\_storage\_name) | n/a |
| <a name="output_backup_policy_id"></a> [backup\_policy\_id](#output\_backup\_policy\_id) | n/a |
| <a name="output_backup_repeating_time_intervals"></a> [backup\_repeating\_time\_intervals](#output\_backup\_repeating\_time\_intervals) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_location"></a> [location](#output\_location) | n/a |
| <a name="output_name"></a> [name](#output\_name) | Description: This file contains the output variables for the data protection backup policy and instance resources. |
| <a name="output_operational_default_retention_duration"></a> [operational\_default\_retention\_duration](#output\_operational\_default\_retention\_duration) | n/a |
| <a name="output_retention_rule"></a> [retention\_rule](#output\_retention\_rule) | n/a |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | n/a |
| <a name="output_time_zone"></a> [time\_zone](#output\_time\_zone) | n/a |
| <a name="output_vault_default_retention_duration"></a> [vault\_default\_retention\_duration](#output\_vault\_default\_retention\_duration) | n/a |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | n/a |

#### The following resources are created by this module:


- resource.azurerm_data_protection_backup_instance_blob_storage.data_protection_backup_instance_blob_storage (/usr/agent/azp/_work/1/s/amn-az-tfm-backup-blob-storage/main.tf#36)
- resource.azurerm_data_protection_backup_policy_blob_storage.data_protection_backup_policy_blob_storage (/usr/agent/azp/_work/1/s/amn-az-tfm-backup-blob-storage/main.tf#1)


## Example Scenario

Create a Backup Blob Storage <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create a Backup Blob Storage

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
  resource_group_suffix  = "rg"
  backup_vault_suffix    = "bv"
  backup_policy_suffix   = "bp"
  backup_instance_suffix = "bis"
  storage_account_suffix = "sa"
  environment_suffix     = "t01"
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
  region_abbreviation               = local.us_region_abbreviations[var.location]
  resource_group_name               = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  backup_vault_name                 = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_vault_suffix}-${local.environment_suffix}"
  backup_policy_name                = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_policy_suffix}-${local.environment_suffix}"
  backup_instance_blob_storage_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.backup_instance_suffix}-${local.environment_suffix}"
  storage_account_name              = "co${local.region_abbreviation}tfm${random_string.resource_name.result}${local.storage_account_suffix}${local.environment_suffix}"
  containers_list                   = [for container in var.containers_list : container.name]
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
  depends_on          = [module.rg]
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-backupvault?ref=v1.0.1"
  name                = local.backup_vault_name
  location            = var.location
  resource_group_name = local.resource_group_name
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
  identity            = var.identity
}

module "storage" {
  depends_on = [module.rg]
  source     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-storage-account?ref=v1.0.0"
  #version = "1.0.0"
  resource_group_name                  = local.resource_group_name
  location                             = var.location
  storage_account_name                 = local.storage_account_name
  skuname                              = var.skuname
  account_kind                         = var.account_kind
  container_soft_delete_retention_days = var.container_soft_delete_retention_days
  blob_soft_delete_retention_days      = var.blob_soft_delete_retention_days
  public_network_access_enabled        = var.public_network_access_enabled
  containers_list                      = var.containers_list
  tags                                 = var.tags
}

module "role_assignments" {
  depends_on = [module.rg, module.storage, module.backup_vault]
  source     = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-role-assignment?ref=v1.0.0"

  system_assigned_managed_identities_by_principal_id = {
    mi1 = module.backup_vault.backup_vault_identity[0].principal_id
  }
  role_definitions = {
    role1 = var.role_definition_name
  }
  role_assignments_for_scopes = {
    example1 = {
      scope = module.storage.storage_account_id
      role_assignments = {
        role_assignment_1 = {
          role_definition                    = "role1"
          system_assigned_managed_identities = ["mi1"]
        }
      }
    }
  }
}

module "backup_policy_blob_storage" {
  depends_on                             = [module.rg, module.backup_vault, module.storage, module.role_assignments]
  source                                 = "../"
  backup_policy_blob_storage_name        = local.backup_policy_name
  vault_id                               = module.backup_vault.id
  backup_repeating_time_intervals        = var.backup_repeating_time_intervals
  operational_default_retention_duration = var.operational_default_retention_duration
  vault_default_retention_duration       = var.vault_default_retention_duration
  time_zone                              = var.time_zone
  retention_rule                         = var.retention_rule
  location                               = var.location
  storage_account_id                     = module.storage.storage_account_id
  storage_account_container_names        = local.containers_list
  backup_instance_blob_storage_name      = local.backup_instance_blob_storage_name
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
#general vars
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

#storage account
skuname                              = "Standard_LRS"
account_kind                         = "StorageV2"
public_network_access_enabled        = true
blob_soft_delete_retention_days      = 31
container_soft_delete_retention_days = 31
containers_list = [
  { name = "intelligence-hub", access_type = "private" },
  { name = "zipcodes", access_type = "private" }
]

#role assignment vars
role_definition_name = "Storage Account Backup Contributor"

#backup vault
identity = {
  type = "SystemAssigned"
}
datastore_type  = "VaultStore"
redundancy      = "LocallyRedundant"
backup_repeating_time_intervals        = null
operational_default_retention_duration = "P30D"
vault_default_retention_duration       = null
time_zone                              = null
priority                               = null
retention_rule                         = null
life_cycle                             = null
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->