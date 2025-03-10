<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage signalr in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl

resource "azurerm_signalr_service" "signalr" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  sku {
    capacity = var.sku.capacity
    name     = var.sku.name
  }

  dynamic "identity" {
    for_each = var.identity.identity_ids != [] ? [1] : []

    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }
  
  dynamic "cors" {
    for_each = length(var.allowed_origins) > 0 ? ["fake"] : []
    content {
      allowed_origins = var.allowed_origins
    }
  }

  connectivity_logs_enabled     = var.connectivity_logs_enabled
  messaging_logs_enabled        = var.messaging_logs_enabled
  # `live_trace_enabled` has been deprecated in favor of `live_trace` and will be removed in 4.0.
  // live_trace_enabled            = var.live_trace_enabled
  live_trace {
    enabled                   = var.live_trace_enabled
    messaging_logs_enabled    = var.messaging_logs_enabled
    connectivity_logs_enabled = var.connectivity_logs_enabled
    http_request_logs_enabled = var.http_request_logs_enabled
  }
  service_mode                  = var.service_mode
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

resource "azurerm_signalr_service_network_acl" "networkACLs" {
  signalr_service_id = azurerm_signalr_service.signalr.id
  default_action     = var.network_acl_default_action

  dynamic "public_network" {
    for_each = (var.network_acl_default_action == "Deny") ? toset([1]) : toset([])
    content {
      allowed_request_types = var.public_network_allowed_request_types
    }
  }
  dynamic "public_network" {
    for_each = (var.network_acl_default_action == "Allow") ? toset([1]) : toset([])
    content {
      denied_request_types = var.public_network_denied_request_types
    }
  }

  # TODO: Private endpoint configurations 
  // private_endpoint {
  //   id                    = azurerm_private_endpoint.example.id
  //   allowed_request_types = ["ServerConnection"]
  // }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_origins"></a> [allowed\_origins](#input\_allowed\_origins) | A List of origins which should be able to make cross-origin calls. | `list(string)` | `[]` | no |
| <a name="input_connectivity_logs_enabled"></a> [connectivity\_logs\_enabled](#input\_connectivity\_logs\_enabled) | Specifies if Connectivity Logs are enabled or not | `bool` | `true` | no |
| <a name="input_http_request_logs_enabled"></a> [http\_request\_logs\_enabled](#input\_http\_request\_logs\_enabled) | Specifies if Http Request Logs are enabled or not. | `bool` | `true` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "identity_ids": [],<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_live_trace_enabled"></a> [live\_trace\_enabled](#input\_live\_trace\_enabled) | Specifies if Live Trace is enabled or not | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for SignalR. | `string` | n/a | yes |
| <a name="input_messaging_logs_enabled"></a> [messaging\_logs\_enabled](#input\_messaging\_logs\_enabled) | Specifies if Messaging Logs are enabled or not | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | SignalR resource name | `string` | n/a | yes |
| <a name="input_network_acl_default_action"></a> [network\_acl\_default\_action](#input\_network\_acl\_default\_action) | The default action to control the network access when no other rule matches. Possible values are Allow and Deny. | `string` | `"Deny"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Specifies if the public access is enabled or not. | `bool` | `false` | no |
| <a name="input_public_network_allowed_request_types"></a> [public\_network\_allowed\_request\_types](#input\_public\_network\_allowed\_request\_types) | The allowed request types for the public network. Possible values are ClientConnection, ServerConnection, RESTAPI and Trace. When network\_acl\_default\_action is Allow, public\_network\_allowed\_request\_types cannot be set. | `list(string)` | <pre>[<br>  "ServerConnection",<br>  "ClientConnection",<br>  "RESTAPI",<br>  "Trace"<br>]</pre> | no |
| <a name="input_public_network_denied_request_types"></a> [public\_network\_denied\_request\_types](#input\_public\_network\_denied\_request\_types) | The denied request types for the public network. Possible values are ClientConnection, ServerConnection, RESTAPI and Trace. When network\_acl\_default\_action is Deny, public\_network\_denied\_request\_types cannot be set. | `list(string)` | <pre>[<br>  "ServerConnection",<br>  "ClientConnection",<br>  "RESTAPI",<br>  "Trace"<br>]</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_service_mode"></a> [service\_mode](#input\_service\_mode) | Specifies the service mode | `string` | `"Default"` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Signalr SKU | <pre>object({<br>    name     = string,<br>    capacity = number<br>  })</pre> | <pre>{<br>  "capacity": 1,<br>  "name": "Free_F1"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The FQDN of the SignalR service |
| <a name="output_id"></a> [id](#output\_id) | The ID of the SignalR service. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The publicly accessible IP of the SignalR service |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the SignalR service. |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the SignalR service. |
| <a name="output_public_port"></a> [public\_port](#output\_public\_port) | The publicly accessible port of the SignalR service which is designed for browser/client use. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the SignalR service. |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | The secondary connection string for the SignalR service. |
| <a name="output_server_port"></a> [server\_port](#output\_server\_port) | The publicly accessible port of the SignalR service which is designed for customer server side use. |

#### The following resources are created by this module:


- resource.azurerm_signalr_service.signalr (/usr/agent/azp/_work/1/s/amn-az-tfm-signalr/main.tf#2)
- resource.azurerm_signalr_service_network_acl.networkACLs (/usr/agent/azp/_work/1/s/amn-az-tfm-signalr/main.tf#42)


## Example Scenario

Create signalr <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create signalr

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
  signalr_suffix        = "signalr"
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
  signalr_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.signalr_suffix}-${local.environment_suffix}"
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

module "signalr" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on = [module.rg]
  source  = "../"

  name                = local.signalr_name
  location            = var.location
  resource_group_name = local.resource_group_name

  sku                 = var.sku

  connectivity_logs_enabled            = var.connectivity_logs_enabled
  messaging_logs_enabled               = var.messaging_logs_enabled
  live_trace_enabled                   = var.live_trace_enabled
  service_mode                         = var.service_mode
  public_network_access_enabled        = var.public_network_access_enabled
  public_network_allowed_request_types = var.public_network_allowed_request_types
  tags                                 = var.tags
}

check "signalr_health_check" {
  data "http" "signalr_health" {
     url = "https://${module.signalr.hostname}/api/v1/health"
  }
 
  assert {
     condition     = data.http.signalr_health.status_code == 200 || data.http.signalr_health.status_code == 473
     error_message = "SignalR returned an unhealthy status code"
  }
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location                             = "westus2"
allowed_origins                      = ["*"] 
connectivity_logs_enabled            = true
messaging_logs_enabled               = true
live_trace_enabled                   = true
service_mode                         = "Default"
public_network_access_enabled        = true
network_acl_default_action           = "Deny" 
public_network_allowed_request_types = ["ServerConnection","ClientConnection","RESTAPI","Trace"]
sku                                  = {
                                         name     = "Standard_S1"
                                         capacity = 1
                                       }
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