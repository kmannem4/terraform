<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage virtual network in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#------------------------
# Local declarations
#------------------------
locals {
  if_ddos_enabled = var.create_ddos_plan ? [{}] : []
}

#-------------------------------------
# VNET Creation - Default is "true"
#-------------------------------------

resource "azurerm_virtual_network" "vnet" {
  #checkov:skip=CKV_AZURE_182: "Ensure that VNET has at least 2 connected DNS Endpoints"
  #checkov:skip=CKV_AZURE_183: "Ensure that VNET uses local DNS addresses"

  name                    = var.vnetwork_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  address_space           = var.vnet_address_space
  dns_servers             = var.dns_servers
  tags                    = merge({ "Name" = format("%s", var.vnetwork_name) }, var.tags, )
  flow_timeout_in_minutes = var.flow_timeout_in_minutes == 0 || var.flow_timeout_in_minutes == null ? null : var.flow_timeout_in_minutes
  edge_zone               = var.edge_zone == "" || var.edge_zone == null ? null : var.edge_zone
  dynamic "ddos_protection_plan" {
    for_each = local.if_ddos_enabled

    content {
      id     = azurerm_network_ddos_protection_plan.ddos[0].id
      enable = true
    }
  }
}

#--------------------------------------------
# Ddos protection plan - Default is "false"
#--------------------------------------------

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.create_ddos_plan ? 1 : 0
  name                = var.ddos_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge({ "Name" = format("%s", var.ddos_plan_name) }, var.tags, )
}

#-------------------------------------
# Network Watcher - Default is "true"
#-------------------------------------
resource "azurerm_resource_group" "nwatcher" {
  count    = var.create_network_watcher != false ? 1 : 0
  name     = "NetworkWatcherRG"
  location = var.location
  tags     = merge({ "Name" = "NetworkWatcherRG" }, var.tags, )
}

resource "azurerm_network_watcher" "nwatcher" {
  count               = var.create_network_watcher != false ? 1 : 0
  name                = "NetworkWatcher_${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.nwatcher.0.name
  tags                = merge({ "Name" = format("%s", "NetworkWatcher_${var.location}") }, var.tags, )
}

#--------------------------------------------------------------------------------------------------------
# Subnets Creation with, private link endpoint/servie network policies, service endpoints and Deligation.
#--------------------------------------------------------------------------------------------------------

resource "azurerm_subnet" "fw-snet" {
  #checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  count                = var.firewall_subnet_address_prefix != null ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.firewall_subnet_address_prefix #[cidrsubnet(element(var.vnet_address_space, 0), 10, 0)]
  service_endpoints    = var.firewall_service_endpoints
}

resource "azurerm_subnet" "gw_snet" {
  #checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  count                = var.gateway_subnet_address_prefix != null ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.gateway_subnet_address_prefix #[cidrsubnet(element(var.vnet_address_space, 0), 8, 1)]
  service_endpoints    = var.gateway_service_endpoints
}

resource "azurerm_subnet" "snet" {
  #checkove:skip=CKV_AZURE_160: "Ensure that HTTP (port 80) access is restricted from the internet"
  for_each                                      = var.subnets
  name                                          = each.value.subnet_name
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.subnet_address_prefix
  service_endpoints                             = lookup(each.value, "service_endpoints", [])
  service_endpoint_policy_ids                   = lookup(each.value, "service_endpoint_policy_ids", null)
  private_endpoint_network_policies             = lookup(each.value, "private_endpoint_network_policies_enabled", null)
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}

#-----------------------------------------------
# Network security group - Default is "false"
#-----------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  #checkov:skip=CKV_AZURE_10: "Ensure that SSH access is restricted from the internet"
  #checkov:skip=CKV_AZURE_77: "Ensure that UDP Services are restricted from the Internet "
  #checkov:skip=CKV_AZURE_9: "Ensure that RDP access is restricted from the internet"
  #checkove:skip=CKV_AZURE_160: "Ensure that HTTP (port 80) access is restricted from the internet"

  for_each            = var.subnets
  name                = lower("nsg_${each.key}_in")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge({ "ResourceName" = lower("nsg_${each.key}_in") }, var.tags, )
  dynamic "security_rule" {
    for_each = concat(lookup(each.value, "nsg_inbound_rules", []), lookup(each.value, "nsg_outbound_rules", []))
    content {
      name                       = security_rule.value[0] == "" ? "Default_Rule" : security_rule.value[0]
      priority                   = security_rule.value[1]
      direction                  = security_rule.value[2] == "" ? "Inbound" : security_rule.value[2]
      access                     = security_rule.value[3] == "" ? "Allow" : security_rule.value[3]
      protocol                   = security_rule.value[4] == "" ? "Tcp" : security_rule.value[4]
      source_port_range          = "*"
      destination_port_range     = security_rule.value[5] == "" ? "*" : security_rule.value[5]
      source_address_prefix      = security_rule.value[6] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[6]
      destination_address_prefix = security_rule.value[7] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[7]
      description                = "${security_rule.value[2]}_Port_${security_rule.value[5]}"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_ddos_plan"></a> [create\_ddos\_plan](#input\_create\_ddos\_plan) | Create an ddos plan - Default is false | `bool` | `false` | no |
| <a name="input_create_network_watcher"></a> [create\_network\_watcher](#input\_create\_network\_watcher) | Controls if Network Watcher resources should be created for the Azure subscription | `bool` | `true` | no |
| <a name="input_ddos_plan_name"></a> [ddos\_plan\_name](#input\_ddos\_plan\_name) | The name of AzureNetwork DDoS Protection Plan | `string` | `"azureddosplan01"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of dns servers to use for virtual network | `list(string)` | `[]` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | The edge zone to use for the virtual network | `string` | `""` | no |
| <a name="input_firewall_service_endpoints"></a> [firewall\_service\_endpoints](#input\_firewall\_service\_endpoints) | Service endpoints to add to the firewall subnet | `list(string)` | <pre>[<br>  "Microsoft.AzureActiveDirectory",<br>  "Microsoft.AzureCosmosDB",<br>  "Microsoft.EventHub",<br>  "Microsoft.KeyVault",<br>  "Microsoft.ServiceBus",<br>  "Microsoft.Sql",<br>  "Microsoft.Storage"<br>]</pre> | no |
| <a name="input_firewall_subnet_address_prefix"></a> [firewall\_subnet\_address\_prefix](#input\_firewall\_subnet\_address\_prefix) | The address prefix to use for the Firewall subnet | `any` | `null` | no |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | The flow timeout in minutes | `number` | `0` | no |
| <a name="input_gateway_service_endpoints"></a> [gateway\_service\_endpoints](#input\_gateway\_service\_endpoints) | Service endpoints to add to the Gateway subnet | `list(string)` | `[]` | no |
| <a name="input_gateway_subnet_address_prefix"></a> [gateway\_subnet\_address\_prefix](#input\_gateway\_subnet\_address\_prefix) | The address prefix to use for the gateway subnet | `any` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | A container that holds related resources for an Azure solution | `string` | `"rg-demo-westeurope-01"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | For each subnet, create an object that contain fields | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space to be used for the Azure virtual network. | `list` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_vnetwork_name"></a> [vnetwork\_name](#input\_vnetwork\_name) | Name of your Azure Virtual Network | `string` | `"vnet-azure-westeurope-001"` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ddos_plan_name"></a> [ddos\_plan\_name](#output\_ddos\_plan\_name) | ddos\_plan\_name of Vnet |
| <a name="output_ddos_protection_plan"></a> [ddos\_protection\_plan](#output\_ddos\_protection\_plan) | Ddos protection plan details |
| <a name="output_dns_servers"></a> [dns\_servers](#output\_dns\_servers) | dns\_servers of Vnet |
| <a name="output_edge_zone"></a> [edge\_zone](#output\_edge\_zone) | edge\_zone of Vnet |
| <a name="output_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#output\_flow\_timeout\_in\_minutes) | flow\_timeout\_in\_minutes of Vnet |
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | List of Network security group ids |
| <a name="output_network_security_group_names"></a> [network\_security\_group\_names](#output\_network\_security\_group\_names) | List of Network security group names |
| <a name="output_network_watcher_id"></a> [network\_watcher\_id](#output\_network\_watcher\_id) | ID of Network Watcher |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | The location of the resource group in which resources are created |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | List of address prefix for subnets |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | List of IDs of subnets |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | List of Names of subnets |
| <a name="output_virtual_network_address_space"></a> [virtual\_network\_address\_space](#output\_virtual\_network\_address\_space) | List of address spaces that are used the virtual network. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The id of the virtual network |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the virtual network |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | Vnet |

#### The following resources are created by this module:


- resource.azurerm_network_ddos_protection_plan.ddos (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#38)
- resource.azurerm_network_security_group.nsg (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#115)
- resource.azurerm_network_watcher.nwatcher (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#56)
- resource.azurerm_resource_group.nwatcher (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#49)
- resource.azurerm_subnet.fw-snet (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#68)
- resource.azurerm_subnet.gw_snet (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#78)
- resource.azurerm_subnet.snet (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#88)
- resource.azurerm_subnet_network_security_group_association.nsg-assoc (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#143)
- resource.azurerm_virtual_network.vnet (/usr/agent/azp/_work/1/s/amn-az-tfm-virtual-network/main.tf#12)


## Example Scenario

Create virtual network <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create virtual network

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


module "virtual_network" {
  depends_on                     = [module.rg]
  source                         = "../"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  vnetwork_name                  = var.vnetwork_name
  vnet_address_space             = var.vnet_address_space
  subnets                        = var.subnets
  gateway_subnet_address_prefix  = var.gateway_subnet_address_prefix
  firewall_subnet_address_prefix = var.firewall_subnet_address_prefix
  create_network_watcher         = var.create_network_watcher
  create_ddos_plan               = var.create_ddos_plan
  edge_zone                      = var.edge_zone
  flow_timeout_in_minutes        = var.flow_timeout_in_minutes
  dns_servers                    = var.dns_servers
  tags                           = var.tags
  ddos_plan_name                 = var.ddos_plan_name
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
create_network_watcher  = false
location                = "westus2"
vnetwork_name           = "co-wus2-tftest-vnet-t01"
vnet_address_space      = ["10.0.0.0/16"]
create_ddos_plan        = false
ddos_plan_name          = ""
flow_timeout_in_minutes = 0
subnets = {
  mgnt_subnet1 = {
    subnet_name           = "snet-management1"
    subnet_address_prefix = ["10.0.1.0/24"]
  }
  mgnt_subnet2 = {
    subnet_name           = "snet-management2"
    subnet_address_prefix = ["10.0.2.0/24"]
  }
}

dns_servers                    = []
edge_zone                      = ""
firewall_subnet_address_prefix = ["10.0.3.0/24"]
gateway_subnet_address_prefix  = ["10.0.4.0/24"]
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