<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage data factory in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_data_factory" "data_factory" {
  #checkov:skip=CKV2_AZURE_103: skip
  #checkov:skip=CKV2_AZURE_15: skip
  resource_group_name             = var.resource_group_name
  name                            = var.data_factory_config.data_factory_name
  location                        = var.location
  public_network_enabled          = var.data_factory_config.public_network_enabled
  managed_virtual_network_enabled = var.data_factory_config.managed_virtual_network_enabled

  dynamic "global_parameter" {
    for_each = var.data_factory_config.global_parameter.name != null ? [1] : []
    content {
      name  = var.data_factory_config.global_parameter.name
      type  = var.data_factory_config.global_parameter.type
      value = var.data_factory_config.global_parameter.value
    }
  }

  dynamic "github_configuration" {
    for_each = var.data_factory_config.github_configuration.account_name != null ? [1] : []
    content {
      account_name       = var.data_factory_config.github_configuration.account_name
      branch_name        = var.data_factory_config.github_configuration.branch_name
      git_url            = var.data_factory_config.github_configuration.git_url
      repository_name    = var.data_factory_config.github_configuration.repository_name
      root_folder        = var.data_factory_config.github_configuration.root_folder
      publishing_enabled = var.data_factory_config.github_configuration.publishing_enabled
    }
  }

  dynamic "vsts_configuration" {
    for_each = var.data_factory_config.vsts_configuration.account_name != null ? [1] : []
    content {
      account_name    = var.data_factory_config.vsts_configuration.account_name
      branch_name     = var.data_factory_config.vsts_configuration.branch_name
      project_name    = var.data_factory_config.vsts_configuration.project_name
      repository_name = var.data_factory_config.vsts_configuration.repository_name
      root_folder     = var.data_factory_config.vsts_configuration.root_folder
      tenant_id       = data.azurerm_client_config.current.tenant_id
    }
  }

  dynamic "identity" {
    for_each = var.data_factory_config.identity != null ? [1] : []
    content {
      type = var.data_factory_config.identity
    }
  }

  tags = var.tags
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_factory_config"></a> [data\_factory\_config](#input\_data\_factory\_config) | n/a | <pre>object({<br>    data_factory_name               = string                      # Name of the Azure Data Factory<br>    public_network_enabled          = bool                        # Boolean flag indicating whether the data factory is accessible from a public network<br>    managed_virtual_network_enabled = bool                        # Boolean flag indicating whether the data factory is connected to a managed virtual network<br>    identity                        = optional(string)            # Managed Service Identity (MSI) associated with the data factory, if any<br>    global_parameter = optional(object({                         # Global parameters for the data factory<br>      name  = optional(string)                                   # Name of the global parameter<br>      type  = optional(string)                                   # Type of the global parameter<br>      value = optional(string)                                   # Value of the global parameter<br>    }))<br>    github_configuration = optional(object({                     # GitHub configuration for the data factory<br>      account_name       = optional(string)                      # GitHub account name<br>      branch_name        = optional(string)                      # Branch name in the GitHub repository<br>      git_url            = optional(string)                      # URL of the GitHub repository<br>      repository_name    = optional(string)                      # Name of the GitHub repository<br>      root_folder        = optional(string)                      # Root folder within the GitHub repository<br>      publishing_enabled = optional(string)                      # Boolean flag indicating whether publishing is enabled<br>    }))<br>    vsts_configuration = optional(object({                       # VSTS (Visual Studio Team Services) configuration for the data factory<br>      account_name    = string                                  # VSTS account name<br>      branch_name     = optional(string)                        # Branch name in the VSTS repository<br>      project_name    = string                                  # VSTS project name<br>      repository_name = optional(string)                        # Name of the VSTS repository<br>      root_folder     = optional(string)                        # Root folder within the VSTS repository<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location. | `string` | `"westus2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_factory_id"></a> [data\_factory\_id](#output\_data\_factory\_id) | The ID of the Azure Data Factory |
| <a name="output_data_factory_name"></a> [data\_factory\_name](#output\_data\_factory\_name) | The name of the Azure Data Factory |
| <a name="output_data_factory_outputs"></a> [data\_factory\_outputs](#output\_data\_factory\_outputs) | n/a |

#### The following resources are created by this module:


- resource.azurerm_data_factory.data_factory (/usr/agent/azp/_work/1/s/amn-az-tfm-data-factory/main.tf#3)
- data source.azurerm_client_config.current (/usr/agent/azp/_work/1/s/amn-az-tfm-data-factory/main.tf#1)


## Example Scenario

Create data factory <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create data factory

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

module "data_factory" {
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name =  local.resource_group_name
  data_factory_config = var.data_factory_config
  tags = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location = "westus2"

data_factory_config = {
  data_factory_name = "co-wus2-tftest-adf-t1313"
  public_network_enabled = true
  managed_virtual_network_enabled = true
  identity = "SystemAssigned"
  global_parameter = {}
  github_configuration = {}
  vsts_configuration = {
    account_name = "AMNEngineering"
    branch_name = "main"
    project_name = "AMNOne"
    repository_name = "AMIE2.DataFactory"
    root_folder = "/"
  }
}

tags = {
  charge-to = "101-71200-5000-9500"
  environment = "test"
  application = "Platform Services"
  product = "Platform Services"
  amnonecomponent = "shared"
  role = "infrastructure-tf-unit-test"
  managed-by = "cloud.engineers@amnhealthcare.com"
  owner = "cloud.engineers@amnhealthcare.com"
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->