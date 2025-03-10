<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage Redis in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
resource "azurerm_redis_cache" "redis" {
  for_each            = var.redis_vars
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  capacity            = each.value.capacity
  family              = each.value.family
  sku_name            = each.value.sku_name

  access_keys_authentication_enabled = each.value.access_keys_authentication_enabled
  non_ssl_port_enabled               = each.value.non_ssl_port_enabled

  dynamic "identity" {
    for_each = try([var.redis_vars.identity], [])
    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }
  minimum_tls_version = each.value.minimum_tls_version

  dynamic "patch_schedule" {
    for_each = each.value.patch_schedule == null ? [] : [each.value.patch_schedule]
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = partch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }
  zones                     = each.value.zones
  subnet_id                 = each.value.sku_name == "Premium" ? var.subnet_id : null
  private_static_ip_address = each.value.sku_name == "Premium" && var.subnet_id != null ? var.private_static_ip_address : null

  public_network_access_enabled = each.value.public_network_access_enabled
  dynamic "redis_configuration" {
    for_each = each.value.redis_configuration == null ? [] : [each.value.redis_configuration]
    content {
      aof_backup_enabled              = each.value.sku_name == "Premium" ? redis_configuration.value.aof_backup_enabled : false
      aof_storage_connection_string_0 = redis_configuration.value.aof_storage_connection_string_0
      aof_storage_connection_string_1 = redis_configuration.value.aof_storage_connection_string_1
      #   aof_storage_connection_string_0 = "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.nc-cruks-storage-account.primary_blob_endpoint};AccountName=${azurerm_storage_account.mystorageaccount.name};AccountKey=${azurerm_storage_account.mystorageaccount.primary_access_key}"
      #   aof_storage_connection_string_1 = "DefaultEndpointsProtocol=https;BlobEndpoint=${azurerm_storage_account.mystorageaccount.primary_blob_endpoint};AccountName=${azurerm_storage_account.mystorageaccount.name};AccountKey=${azurerm_storage_account.mystorageaccount.secondary_access_key}"
      authentication_enabled                  = redis_configuration.value.authentication_enabled
      active_directory_authentication_enabled = redis_configuration.value.active_directory_authentication_enabled
      maxmemory_reserved                      = redis_configuration.value.maxmemory_reserved
      maxmemory_delta                         = redis_configuration.value.maxmemory_delta
      maxmemory_policy                        = redis_configuration.value.maxmemory_policy
      data_persistence_authentication_method  = redis_configuration.value.data_persistence_authentication_method
      maxfragmentationmemory_reserved         = redis_configuration.value.maxfragmentationmemory_reserved
      rdb_backup_enabled                      = redis_configuration.value.rdb_backup_enabled
      rdb_backup_frequency                    = redis_configuration.value.rdb_backup_frequency
      rdb_backup_max_snapshot_count           = redis_configuration.value.rdb_backup_max_snapshot_count
      rdb_storage_connection_string           = redis_configuration.value.rdb_backup_enabled == true ? redis_configuration.value.rdb_storage_connection_string : null
      storage_account_subscription_id         = redis_configuration.value.storage_account_subscription_id
      notify_keyspace_events                  = redis_configuration.value.notify_keyspace_events

    }
  }

  replicas_per_master  = each.value["sku_name"] == "Premium" ? each.value["replicas_per_master"] : null
  replicas_per_primary = each.value["sku_name"] == "Premium" ? each.value["replicas_per_primary"] : null
  redis_version        = each.value.redis_version
  tenant_settings      = each.value.tenant_settings
  shard_count          = each.value["sku_name"] == "Premium" ? each.value["shard_count"] : null
  lifecycle {
    # A bug in the Redis API where the original storage connection string isn't being returneds
    ignore_changes = [redis_configuration[0].rdb_storage_connection_string]
  }
}

#----------------------------------------------------------------------
# Adding Firewall rules for Redis Cache Instance - Default is "false"
#----------------------------------------------------------------------
resource "azurerm_redis_firewall_rule" "name" {
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = format("%s", each.key)
  redis_cache_name    = element([for n in azurerm_redis_cache.redis : n.name], 0)
  resource_group_name = var.resource_group_name
  start_ip            = each.value["start_ip"]
  end_ip              = each.value["end_ip"]
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Range of IP addresses to allow firewall connections. | <pre>map(object({<br>    start_ip = string<br>    end_ip   = string<br>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group. | `string` | n/a | yes |
| <a name="input_private_static_ip_address"></a> [private\_static\_ip\_address](#input\_private\_static\_ip\_address) | private static ip address of redis to be created | `string` | `null` | no |
| <a name="input_redis_vars"></a> [redis\_vars](#input\_redis\_vars) | Redis variables | <pre>map(object({<br>    name                               = string<br>    capacity                           = number<br>    family                             = string<br>    sku_name                           = string<br>    access_keys_authentication_enabled = optional(bool)<br>    non_ssl_port_enabled               = optional(bool)<br>    identity = optional(object({<br>      type         = string<br>      identity_ids = optional(list(string))<br>    }))<br>    minimum_tls_version = optional(string)<br>    patch_schedule = optional(object({<br>      day_of_week        = string<br>      start_hour_utc     = optional(string)<br>      maintenance_window = optional(string)<br>    }))<br>    zones                         = optional(list(string))<br>    public_network_access_enabled = optional(bool)<br>    redis_configuration = optional(object({<br>      aof_backup_enabled                      = optional(bool)<br>      aof_storage_connection_string_0         = optional(string)<br>      aof_storage_connection_string_1         = optional(string)<br>      authentication_enabled                  = optional(bool)<br>      active_directory_authentication_enabled = optional(bool)<br>      maxmemory_reserved                      = optional(number)<br>      maxmemory_delta                         = optional(number)<br>      maxmemory_policy                        = optional(string)<br>      data_persistence_authentication_method  = optional(string)<br>      maxfragmentationmemory_reserved         = optional(number)<br>      rdb_backup_enabled                      = optional(bool)<br>      rdb_backup_frequency                    = optional(number)<br>      rdb_backup_max_snapshot_count           = optional(number)<br>      rdb_storage_connection_string           = optional(string)<br>      storage_account_subscription_id         = optional(string)<br>      notify_keyspace_events                  = optional(string)<br>    }))<br>    replicas_per_master  = optional(number)<br>    replicas_per_primary = optional(number)<br>    redis_version        = optional(string)<br>    tenant_settings      = optional(map(string))<br>    shard_count          = optional(number)<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | subnet id of redis to be created | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_name"></a> [redis\_name](#output\_redis\_name) | Redis host name |

#### The following resources are created by this module:


- resource.azurerm_redis_cache.redis (/usr/agent/azp/_work/1/s/amn-az-tfm-redis/main.tf#1)
- resource.azurerm_redis_firewall_rule.name (/usr/agent/azp/_work/1/s/amn-az-tfm-redis/main.tf#75)


## Example Scenario

Create Redis cache <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create Redis cache <br />- Create Redis cache firewall rule

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
  redis_suffix          = "redis"
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

  # resource_group_name   = "co-wus2-amnoneshared-rg-t02"
  resource_group_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  redis_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.redis_suffix}-${local.environment_suffix}"

  redis_vars = {
    "test-redis" = {
      name                = local.redis_name
      capacity            = 1
      family              = "C"
      sku_name            = "Basic"
      minimum_tls_version = "1.2"
      redis_configuration = {
        authentication_enabled                  = true
        active_directory_authentication_enabled = true
      }
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

module "redis" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
  redis_vars          = local.redis_vars
  firewall_rules      = var.firewall_rules
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

# Azure Cache for Redis firewall filter rules are used to provide specific source IP access. 
# Azure Redis Cache access is determined based on start and end IP address range specified. 
# As a rule, only specific IP addresses should be granted access, and all others denied.
# "name" (ex. azure_to_azure or desktop_ip) may only contain alphanumeric characters and underscores
firewall_rules = {
  access_to_azure = {
    start_ip = "0.0.0.0"
    end_ip   = "255.255.255.255"
  }
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->