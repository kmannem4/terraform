<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to configure diagnostic settings of azure resource to collect logs and metrics to monitor the health and performance.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
# Retrieve diagnostic categories for the target resource
data "azurerm_monitor_diagnostic_categories" "categories" {
  # Create the resource only if diagnostic settings are enabled
  count = local.enabled ? 1 : 0

  # Resource ID of the target resource
  resource_id = var.resource_id
}

# Create a diagnostic setting for the target resource
resource "azurerm_monitor_diagnostic_setting" "diagnostic" {
  # Create the resource only if diagnostic settings are enabled
  count = local.enabled ? 1 : 0

  # Name of the diagnostic setting
  name = var.diag_name

  # Resource ID of the target resource
  target_resource_id = var.resource_id

  # Commented out options for other log destinations
  # storage_account_id             = local.storage_id

  # Set the Log Analytics Workspace ID if provided
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Set the Log Analytics destination type if provided
  log_analytics_destination_type = local.log_analytics_destination_type

  # Commented out options for Event Hub destination
  # eventhub_authorization_rule_id = local.eventhub_authorization_rule_id
  # eventhub_name                  = local.eventhub_name

  # Dynamically configure enabled logs based on the log_categories local
  dynamic "enabled_log" {
    for_each = local.log_categories

    content {
      category = enabled_log.value
    }
  }

  # Dynamically configure metrics based on the metrics local
  dynamic "metric" {
    for_each = local.metrics

    content {
      category = metric.key
      enabled  = metric.value.enabled
    }
  }

  # Ignore changes to log_analytics_destination_type during updates
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_diag_name"></a> [diag\_name](#input\_diag\_name) | Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_excluded_log_categories"></a> [excluded\_log\_categories](#input\_excluded\_log\_categories) | List of log categories to exclude. | `list(string)` | `[]` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | When set to 'Dedicated' logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Resource ID of LAW. | `string` | `null` | no |
| <a name="input_log_categories"></a> [log\_categories](#input\_log\_categories) | List of log categories. Defaults to all available. | `list(string)` | `null` | no |
| <a name="input_logs_destinations_ids"></a> [logs\_destinations\_ids](#input\_logs\_destinations\_ids) | List of destination resources IDs for logs diagnostic destination.<br>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br>If you want to use Azure EventHub as destination, you must provide a formatted string with both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character. | `list(string)` | n/a | yes |
| <a name="input_metric_categories"></a> [metric\_categories](#input\_metric\_categories) | List of metric categories. Defaults to all available. | `list(string)` | `null` | no |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The ID of the resource on which activate the diagnostic settings. | `string` | n/a | yes |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_id"></a> [diagnostic\_settings\_id](#output\_diagnostic\_settings\_id) | ID of the Diagnostic Settings. |
| <a name="output_target_resource_id"></a> [target\_resource\_id](#output\_target\_resource\_id) | resource id of the target resource |

#### The following resources are created by this module:


- resource.azurerm_monitor_diagnostic_setting.diagnostic (/usr/agent/azp/_work/1/s/amn-az-tfm-diagnostic-setting/main.tf#11)
- data source.azurerm_monitor_diagnostic_categories.categories (/usr/agent/azp/_work/1/s/amn-az-tfm-diagnostic-setting/main.tf#2)


## Example Scenario

Create resource group, storage account resource and configure below diagnostic settings for storage account to collect logs and metrics to monitor the health and performance.<br /><br /> - Configure the Log Analytics Workspace ID (log_analytics_workspace_id) for routing diagnostic data.<br /> - Configure the destination type (log_analytics_destination_type) as Dedicated to ensure logs sent to the Log Analytics workspace are stored in resource-specific tables instead of the legacy AzureDiagnostics table.<br />

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
# Generate a random string with a length of 5 characters
# consisting of lowercase letters and numbers.
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Define local variables.
locals {
  # Suffixes for resource names.
  resource_group_suffix = "rg"
  storage_suffix        = "sa"
  diag_suffix           = "diag"
  environment_suffix    = "t01"

  # Mapping of US region names to abbreviations.
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

  # Get the region abbreviation based on the provided location.
  region_abbreviation = local.us_region_abbreviations[var.location]

  # Construct resource names using the region abbreviation and suffixes.
  resource_group_name  = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  diag_name            = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.diag_suffix}-${local.environment_suffix}"
  storage_account_name = "co${local.region_abbreviation}${random_string.resource_name.result}${local.diag_suffix}${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
# Module to create a resource group
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0" # Source for the resource group module
  resource_group_name = local.resource_group_name                                                                          # Name of the resource group
  location            = var.location                                                                                       # Location of the resource group
  tags                = var.tags                                                                                           # Tags to assign to the resource group
}

# Module to create a storage account
module "storage" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  #checkov:skip=CKV_AZURE_244: "Avoid the use of local users for Azure Storage unless necessary"
  depends_on           = [module.rg]                                                                                          # The storage account depends on the resource group
  source               = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-storage-account?ref=v1.0.0" # Source for the storage account module
  resource_group_name  = local.resource_group_name                                                                            # Name of the resource group
  location             = var.location                                                                                         # Location of the storage account
  storage_account_name = local.storage_account_name                                                                           # Name of the storage account
  containers_list      = var.containers_list                                                                                  # List of containers to create
  tags                 = var.tags                                                                                             # Tags to assign to the storage account
}

# Module to create a diagnostic setting
module "diagnostic" {
  depends_on = [module.rg] # The diagnostic setting depends on the resource group
  source     = "../"       # Source for the diagnostic setting module

  diag_name                      = local.diag_name                   # Name of the diagnostic setting
  resource_id                    = module.storage.storage_account_id # Resource ID to monitor
  log_analytics_workspace_id     = var.log_analytics_workspace_id    # Log Analytics workspace ID
  log_analytics_destination_type = "Dedicated"                       # Type of Log Analytics destination
  logs_destinations_ids = [
    var.log_analytics_workspace_id # Log Analytics workspace ID
  ]
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
# Setting the location for Azure resources
location = "westus2"

# Assigning the resource ID of the Log Analytics Workspace
log_analytics_workspace_id = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"

# Defining tags to be applied to resources
tags = {
  charge-to       = "101-71200-5000-9500"               # Cost allocation or tracking
  environment     = "test"                              # Environment (e.g., dev, test, prod)
  application     = "Platform Services"                 # Application name
  product         = "Platform Services"                 # Product name
  amnonecomponent = "shared"                            # Component or service 
  role            = "infrastructure-tf-unit-test"       # Role or purpose
  managed-by      = "cloud.engineers@amnhealthcare.com" # Team or individual responsible for management
  owner           = "cloud.engineers@amnhealthcare.com" # Team or individual owning the resource
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->