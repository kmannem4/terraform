<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage managed instance and managed instance database in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
#-----------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.managed_instance
  name                = each.value.network_config_virtual_network_name
  location            = var.location
  resource_group_name = each.value.network_config_virtual_network_resource_group_name
  address_space       = each.value.vnet_address_space
}

resource "azurerm_subnet" "snet" {
  #checkove:skip=CKV_AZURE_160: "Ensure that HTTP (port 80) access is restricted from the internet"
  for_each             = var.managed_instance
  name                 = each.value.network_config_subnet_name
  resource_group_name  = each.value.network_config_virtual_network_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = each.value.subnet_address_prefix

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

  for_each            = var.managed_instance
  name                = lower("nsg_${each.key}_in")
  resource_group_name = each.value.network_config_virtual_network_resource_group_name
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
  for_each                  = var.managed_instance
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_route_table" "example" {
  for_each            = var.managed_instance
  name                = "routetable-${each.key}-mi"
  location            = var.location
  resource_group_name = each.value.network_config_virtual_network_resource_group_name
  depends_on = [
    azurerm_subnet.snet
  ]
}


resource "azurerm_subnet_route_table_association" "example" {
  for_each       = var.managed_instance
  subnet_id      = azurerm_subnet.snet[each.key].id
  route_table_id = azurerm_route_table.example[each.key].id
}
#-----------------------------------------------------------
# Azure SQL Managed Instance
#-----------------------------------------------------------
resource "azurerm_mssql_managed_instance" "mssql_mi" {
  depends_on                   = [azurerm_subnet_route_table_association.example, azurerm_subnet_network_security_group_association.nsg-assoc]
  for_each                     = var.managed_instance
  name                         = each.value.mssql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  tags                         = var.tags
  administrator_login          = each.value.administrator_login
  administrator_login_password = each.value.administrator_login_password
  vcores                       = each.value.vcores
  storage_size_in_gb           = each.value.storage_size_in_gb
  license_type                 = each.value.license_type
  sku_name                     = each.value.sku_name
  subnet_id                    = azurerm_subnet.snet[each.key].id
  # The for_each argument is a map, and each.key is a string that is the key of the map.
  # The azurerm_subnet.snet object is also a map, and the key of this map is the same as the key of the for_each argument.
  # So, when we use each.key here, we are referencing the key of the map, which is the name of the subnet that we want to use for the managed instance.

  collation                      = each.value.collation
  maintenance_configuration_name = each.value.maintenance_configuration_name
  dynamic "identity" {
    for_each = try([var.managed_instance.identity], [])
    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }
  minimum_tls_version          = each.value.minimum_tls_version
  proxy_override               = each.value.proxy_override
  public_data_endpoint_enabled = each.value.public_data_endpoint_enabled
  zone_redundant_enabled       = each.value.zone_redundant_enabled
  storage_account_type         = each.value.storage_account_type
  dns_zone_partner_id          = each.value.dns_zone_partner_id
  timezone_id                  = each.value.timezone_id
}
#-----------------------------------------------------------
resource "azurerm_mssql_managed_database" "mssql_mi_database" {
  for_each            = var.managed_instance
  name                = each.value.mssql_database_name
  managed_instance_id = azurerm_mssql_managed_instance.mssql_mi[each.key].id

  dynamic "long_term_retention_policy" {
    for_each = each.value.long_term_retention_policy != null ? [each.value.long_term_retention_policy] : []
    content {
      weekly_retention  = try(each.value.long_term_retention_policy.weekly_retention, null)
      monthly_retention = try(each.value.long_term_retention_policy.monthly_retention, null)
      yearly_retention  = try(each.value.long_term_retention_policy.yearly_retention, null)
      week_of_year      = try(each.value.long_term_retention_policy.week_of_year, 1)
    }
  }

  short_term_retention_days = lookup(each.value, "short_term_retention_days", null)

  dynamic "point_in_time_restore" {
    for_each = each.value.point_in_time_restore != null ? [each.value.point_in_time_restore] : []
    content {
      source_database_id    = point_in_time_restore.value["source_database_id"]
      restore_point_in_time = point_in_time_restore.value["restore_point_in_time"]
    }
  }
  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Resource group location | `string` | n/a | yes |
| <a name="input_managed_instance"></a> [managed\_instance](#input\_managed\_instance) | n/a | <pre>map(object({<br>    mssql_server_name              = string<br>    mssql_database_name            = string<br>    administrator_login            = string<br>    administrator_login_password   = string<br>    vcores                         = number<br>    storage_size_in_gb             = number<br>    license_type                   = string<br>    sku_name                       = string<br>    collation                      = optional(string)<br>    maintenance_configuration_name = optional(string)<br>    identity = optional(list(object({<br>      type         = string<br>      identity_ids = optional(string)<br>    })))<br>    minimum_tls_version          = optional(string)<br>    proxy_override               = optional(string)<br>    public_data_endpoint_enabled = optional(string)<br>    zone_redundant_enabled       = optional(string)<br>    storage_account_type         = optional(string)<br>    dns_zone_partner_id          = optional(string)<br>    timezone_id                  = optional(string)<br>    long_term_retention_policy = optional(object({<br>      weekly_retention  = optional(string)<br>      monthly_retention = optional(string)<br>      yearly_retention  = optional(string)<br>      week_of_year      = optional(string)<br>    }))<br>    short_term_retention_days = optional(string)<br>    point_in_time_restore = optional(object({<br>      source_database_id    = string<br>      restore_point_in_time = string<br>    }))<br><br>    network_config_virtual_network_name                = string<br>    network_config_virtual_network_resource_group_name = string<br>    vnet_address_space                                 = list(string)<br>    network_config_subnet_name                         = string<br>    subnet_address_prefix                              = list(string)<br>    delegation = optional(object({<br>      name = string<br>      service_delegation = optional(object({<br>        name    = string<br>        actions = list(string)<br>      }))<br>    }))<br>    nsg_inbound_rules  = optional(list(list(string)))<br>    nsg_outbound_rules = optional(list(list(string)))<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mssql_mi_database_output"></a> [mssql\_mi\_database\_output](#output\_mssql\_mi\_database\_output) | The ID and name of the Azure SQL Managed Instance database. |
| <a name="output_mssql_mi_output"></a> [mssql\_mi\_output](#output\_mssql\_mi\_output) | The ID, FQDN and DNS zone of the Azure SQL Managed Instance. |

#### The following resources are created by this module:


- resource.azurerm_mssql_managed_database.mssql_mi_database (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#123)
- resource.azurerm_mssql_managed_instance.mssql_mi (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#87)
- resource.azurerm_network_security_group.nsg (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#34)
- resource.azurerm_route_table.example (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#68)
- resource.azurerm_subnet.snet (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#11)
- resource.azurerm_subnet_network_security_group_association.nsg-assoc (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#62)
- resource.azurerm_subnet_route_table_association.example (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#79)
- resource.azurerm_virtual_network.vnet (/usr/agent/azp/_work/1/s/amn-az-tfm-mssql-mi-server/main.tf#3)


## Example Scenario

Create Managed Instance server and database <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create virtual network <br /> - Create subnet and nsg rules <br /> - Create Managed Instance server and database

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
  resource_group_suffix   = "rg"
  managed_instance_suffix = "mi"
  vnet_suffix             = "vnet"
  subnet_suffix           = "snet"
  environment_suffix      = "t01"
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

  # resource_group_name   = "co-wus2-amnoneshared-rg-t02"
  resource_group_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  vnet_name           = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suffix}-${local.environment_suffix}"
  subnet_name         = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.subnet_suffix}-${local.environment_suffix}"
  mssql_server_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.managed_instance_suffix}-server-${local.environment_suffix}"
  mssql_database_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.managed_instance_suffix}-database-${local.environment_suffix}"
  managed_instance = {
    "managed_instance_1" = {
      mssql_server_name              = local.mssql_server_name
      mssql_database_name            = local.mssql_database_name
      administrator_login            = "mssqladmin"
      administrator_login_password   = "H@Sh1CoR3!"
      vcores                         = 4
      storage_size_in_gb             = 32
      license_type                   = "BasePrice"
      sku_name                       = "GP_Gen5"
      maintenance_configuration_name = "SQL_Default"
      identity = [{
        type         = "SystemAssigned"
        identity_ids = null
      }]
      is_network_config_required   = true
      minimum_tls_version          = "1.2"
      public_data_endpoint_enabled = false
      zone_redundant_enabled       = false
      storage_account_type         = "LRS"
      dns_zone_partner_id          = null
      timezone_id                  = "UTC"
      short_term_retention_days    = 7
      long_term_retention_policy = {
        yearly_retention = "P1Y"
        week_of_year     = 1
      }
      network_config_virtual_network_name                = local.vnet_name
      network_config_virtual_network_resource_group_name = local.resource_group_name
      vnet_address_space                                 = ["10.0.0.0/16"]
      network_config_subnet_name                         = local.subnet_name
      subnet_address_prefix                              = ["10.0.0.0/24"]

      delegation = {
        name = "managedinstancedelegation"

        service_delegation = {
          name    = "Microsoft.Sql/managedInstances"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
        }
      }
      nsg_inbound_rules = [
        # [Rule Name, Priority, Direction, Access, Protocol, Destination Port Range, Source Address Prefix, Destination Address Prefix]
        ["allow_management_inbound_9000", "106", "Inbound", "Allow", "Tcp", "9000", "*", "*"],         # SQL Management port (TCP 9000)
        ["allow_management_inbound_9003", "107", "Inbound", "Allow", "Tcp", "9003", "*", "*"],         # SQL Management port (TCP 9003)
        ["allow_management_inbound_1438", "108", "Inbound", "Allow", "Tcp", "1438", "*", "*"],         # SQL Management port (TCP 1438)
        ["allow_management_inbound_1440", "109", "Inbound", "Allow", "Tcp", "1440", "*", "*"],         # SQL Management port (TCP 1440)
        ["allow_management_inbound_1452", "110", "Inbound", "Allow", "Tcp", "1452", "*", "*"],         # SQL Management port (TCP 1452)
        ["allow_misubnet_inbound", "200", "Inbound", "Allow", "*", "*", "10.0.0.0/24", "*"],           # Allow inbound traffic from the subnet to the managed instance
        ["allow_health_probe_inbound", "300", "Inbound", "Allow", "*", "*", "AzureLoadBalancer", "*"], # Allow inbound traffic from Azure Load Balancer health probe
        ["allow_tds_inbound", "1000", "Inbound", "Allow", "Tcp", "1433", "VirtualNetwork", "*"],       # Allow inbound traffic from the subnet to the managed instance
        ["deny_all_inbound", "4096", "Inbound", "Deny", "*", "*", "*", "*"]                            # Deny all inbound traffic
      ]

      nsg_outbound_rules = [
        # [Rule Name, Priority, Direction, Access, Protocol, Destination Port Range, Source Address Prefix, Destination Address Prefix]
        ["allow_management_outbound_80", "102", "Outbound", "Allow", "Tcp", "80", "*", "*"],       # Allow outbound traffic to the internet
        ["allow_management_outbound_443", "103", "Outbound", "Allow", "Tcp", "443", "*", "*"],     # Allow outbound traffic to the internet
        ["allow_management_outbound_12000", "104", "Outbound", "Allow", "Tcp", "12000", "*", "*"], # Allow outbound traffic to the internet
        ["allow_misubnet_outbound", "200", "Outbound", "Allow", "*", "*", "10.0.0.0/24", "*"],     # Allow outbound traffic to the subnet
        ["deny_all_outbound", "4096", "Outbound", "Deny", "*", "*", "*", "*"]                      # Deny all outbound traffic
      ]

    }
  }

} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
# Azurerm Provider configuration
module "rg" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "mssql_mi_server" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  location            = var.location
  managed_instance    = local.managed_instance
  tags                = var.tags
}

``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location = "westus2"

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