<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage key vault in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl

locals {
  access_policies = [
    for p in var.access_policies : merge({
      azure_ad_group_names             = []
      object_ids                       = []
      azure_ad_user_principal_names    = []
      certificate_permissions          = []
      key_permissions                  = []
      secret_permissions               = []
      storage_permissions              = []
      azure_ad_service_principal_names = []
    }, p)
  ]

  azure_ad_group_names             = distinct(flatten(local.access_policies[*].azure_ad_group_names))
  azure_ad_user_principal_names    = distinct(flatten(local.access_policies[*].azure_ad_user_principal_names))
  azure_ad_service_principal_names = distinct(flatten(local.access_policies[*].azure_ad_service_principal_names))

  group_object_ids = { for g in data.azuread_group.adgrp : lower(g.display_name) => g.id }
  user_object_ids  = { for u in data.azuread_user.adusr : lower(u.user_principal_name) => u.id }
  spn_object_ids   = { for s in data.azuread_service_principal.adspn : lower(s.display_name) => s.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.azure_ad_service_principal_names : {
          object_id               = local.spn_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }

  combined_access_policies = [
    for k, v in local.grouped_access_policies : {
      object_id               = k
      certificate_permissions = distinct(flatten(v[*].certificate_permissions))
      key_permissions         = distinct(flatten(v[*].key_permissions))
      secret_permissions      = distinct(flatten(v[*].secret_permissions))
      storage_permissions     = distinct(flatten(v[*].storage_permissions))
    }
  ]

  service_principal_object_id = data.azurerm_client_config.current.object_id

  self_permissions = {
    object_id               = local.service_principal_object_id
    tenant_id               = data.azurerm_client_config.current.tenant_id
    key_permissions         = var.self_key_permissions_access_policy
    secret_permissions      = var.self_secret_permissions_access_policy
    certificate_permissions = var.self_certificate_permissions_access_policy
    storage_permissions     = var.self_storage_permissions_access_policy
  }
}

data "azuread_group" "adgrp" {
  count        = length(local.azure_ad_group_names)
  display_name = local.azure_ad_group_names[count.index]
}

data "azuread_user" "adusr" {
  count               = length(local.azure_ad_user_principal_names)
  user_principal_name = local.azure_ad_user_principal_names[count.index]
}

data "azuread_service_principal" "adspn" {
  count        = length(local.azure_ad_service_principal_names)
  display_name = local.azure_ad_service_principal_names[count.index]
}

#----------------------------------------------------------
# Resource Group Creation or selection - Default is "true"
#----------------------------------------------------------
data "azurerm_client_config" "current" {}

#-------------------------------------------------
# Keyvault Creation - Default is "true"
#-------------------------------------------------
resource "azurerm_key_vault" "key_vault" {
  #checkov:skip=CKV_AZURE_110: "Ensure that key vault enables purge protection"
  #checkov:skip=CKV_AZURE_42: "Ensure the key vault is recoverable"
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_pricing_tier
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.enable_purge_protection

  tags = merge({ "ResourceName" = lower("kv-${var.key_vault_name}") }, var.tags, )

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "access_policy" {
    for_each = local.combined_access_policies
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  dynamic "access_policy" {
    for_each = local.service_principal_object_id != "" ? [local.self_permissions] : []
    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  dynamic "contact" {
    for_each = var.certificate_contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#-----------------------------------------------------------------------------------
# Keyvault Secret - Random password Creation if value is empty - Default is "false"
#-----------------------------------------------------------------------------------

resource "random_password" "passwd" {
  for_each    = { for k, v in var.secrets : k => v if v == "" }
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  min_special = 4

  keepers = {
    name = each.key
  }
}

resource "azurerm_key_vault_secret" "keys" {
  #checkov:skip=CKV_AZURE_41: "Ensure that the expiration date is set on all secrets"
  #checkov:skip=CKV_AZURE_114: "Ensure that key vault secrets have "content_type" set"
  for_each     = var.secrets
  name         = each.key
  value        = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id = azurerm_key_vault.key_vault.id

  lifecycle {
    ignore_changes = [
      tags,
      value,
    ]
  }
}

#---------------------------------------------------------
# Private Link for Keyvault - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint && var.existing_vnet_id == null ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "snet-ep" {
  count                                     = var.enable_private_endpoint && var.existing_subnet_id == null ? 1 : 0
  name                                      = "snet-endpoint-${var.location}"
  resource_group_name                       = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01.0.resource_group_name : element(split("/", var.existing_vnet_id), 4)
  virtual_network_name                      = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01.0.name : element(split("/", var.existing_vnet_id), 8)
  address_prefixes                          = var.private_subnet_address_prefix
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", var.key_vault_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet-ep.0.id : var.existing_subnet_id
  tags                = merge({ "Name" = format("%s-private-endpoint", var.key_vault_name) }, var.tags, )

  private_service_connection {
    name                           = "keyvault-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1.0.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_key_vault.key_vault]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = merge({ "Name" = format("%s", "KeyVault-Private-DNS-Zone") }, var.tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  virtual_network_id    = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01.0.id : var.existing_vnet_id
  registration_enabled  = true
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_key_vault.key_vault.name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | List of access policies for the Key Vault. | `list` | `[]` | no |
| <a name="input_certificate_contacts"></a> [certificate\_contacts](#input\_certificate\_contacts) | Contact information to send notifications | <pre>list(object({<br>    email = string<br>    name  = optional(string)<br>    phone = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Private Endpoint to Azure Container Registry | `bool` | `false` | no |
| <a name="input_enable_purge_protection"></a> [enable\_purge\_protection](#input\_enable\_purge\_protection) | Is Purge Protection enabled | `bool` | `false` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Flag to RBAC for authorization | `bool` | `false` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Flag to allow Virtual Machines to retrieve certificates stored as secrets. | `bool` | `true` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Flag to allow Disk Encryption to retrieve secrets | `bool` | `true` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Flag to allow Resource Manager to retrieve secrets | `bool` | `true` | no |
| <a name="input_existing_private_dns_zone"></a> [existing\_private\_dns\_zone](#input\_existing\_private\_dns\_zone) | Existing private DNS zone | `any` | `null` | no |
| <a name="input_existing_subnet_id"></a> [existing\_subnet\_id](#input\_existing\_subnet\_id) | Existing subnet | `any` | `null` | no |
| <a name="input_existing_vnet_id"></a> [existing\_vnet\_id](#input\_existing\_vnet\_id) | Existing Virtual network | `any` | `null` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Name of the key vault | `string` | `""` | no |
| <a name="input_key_vault_sku_pricing_tier"></a> [key\_vault\_sku\_pricing\_tier](#input\_key\_vault\_sku\_pricing\_tier) | SKU used for the Key Vault. The options are: `standard`, `premium`. | `string` | `"standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location | `string` | `""` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network rules to apply to key vault. | <pre>object({<br>    bypass                     = string<br>    default_action             = string<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_private_subnet_address_prefix"></a> [private\_subnet\_address\_prefix](#input\_private\_subnet\_address\_prefix) | address prefix of the subnet for private endpoints | `any` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Is public network access enabled | `bool` | `true` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | The desired length of random password created by this module | `number` | `32` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | resource group name | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map of secrets for the Key Vault. | `map(string)` | `{}` | no |
| <a name="input_self_certificate_permissions_access_policy"></a> [self\_certificate\_permissions\_access\_policy](#input\_self\_certificate\_permissions\_access\_policy) | List of access policies for the Key Vault. | `list` | `[]` | no |
| <a name="input_self_key_permissions_access_policy"></a> [self\_key\_permissions\_access\_policy](#input\_self\_key\_permissions\_access\_policy) | List of access policies for the Key Vault. | `list` | `[]` | no |
| <a name="input_self_secret_permissions_access_policy"></a> [self\_secret\_permissions\_access\_policy](#input\_self\_secret\_permissions\_access\_policy) | List of access policies for the Key Vault. | `list` | `[]` | no |
| <a name="input_self_storage_permissions_access_policy"></a> [self\_storage\_permissions\_access\_policy](#input\_self\_storage\_permissions\_access\_policy) | List of access policies for the Key Vault. | `list` | `[]` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Days for soft-deleted | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add | `map(string)` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | virtual network | `string` | `""` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault"></a> [key\_vault](#output\_key\_vault) | key vault created. |
| <a name="output_key_vault_enable_rbac_authorization"></a> [key\_vault\_enable\_rbac\_authorization](#output\_key\_vault\_enable\_rbac\_authorization) | value of key vault enable\_rbac\_authorization |
| <a name="output_key_vault_enabled_for_deployment"></a> [key\_vault\_enabled\_for\_deployment](#output\_key\_vault\_enabled\_for\_deployment) | value of key vault enabled\_for\_deployment |
| <a name="output_key_vault_enabled_for_disk_encryption"></a> [key\_vault\_enabled\_for\_disk\_encryption](#output\_key\_vault\_enabled\_for\_disk\_encryption) | value of key vault enabled\_for\_disk\_encryption |
| <a name="output_key_vault_enabled_for_template_deployment"></a> [key\_vault\_enabled\_for\_template\_deployment](#output\_key\_vault\_enabled\_for\_template\_deployment) | value of key vault enabled\_for\_template\_deployment |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | Key Vault ID. |
| <a name="output_key_vault_location"></a> [key\_vault\_location](#output\_key\_vault\_location) | key vault created. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | key vault created. |
| <a name="output_key_vault_public_network_access_enabled"></a> [key\_vault\_public\_network\_access\_enabled](#output\_key\_vault\_public\_network\_access\_enabled) | value of key vault public\_network\_access\_enabled |
| <a name="output_key_vault_purge_protection_enabled"></a> [key\_vault\_purge\_protection\_enabled](#output\_key\_vault\_purge\_protection\_enabled) | key vault created. |
| <a name="output_key_vault_resource_group_name"></a> [key\_vault\_resource\_group\_name](#output\_key\_vault\_resource\_group\_name) | key vault created. |
| <a name="output_key_vault_sku_name"></a> [key\_vault\_sku\_name](#output\_key\_vault\_sku\_name) | key vault SKU name. |
| <a name="output_key_vault_soft_delete_retention_days"></a> [key\_vault\_soft\_delete\_retention\_days](#output\_key\_vault\_soft\_delete\_retention\_days) | key vault created. |

#### The following resources are created by this module:


- resource.azurerm_key_vault.key_vault (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#118)
- resource.azurerm_key_vault_secret.keys (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#202)
- resource.azurerm_private_dns_a_record.arecord1 (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#288)
- resource.azurerm_private_dns_zone.dnszone1 (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#265)
- resource.azurerm_private_dns_zone_virtual_network_link.vent-link1 (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#272)
- resource.azurerm_private_endpoint.pep1 (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#236)
- resource.azurerm_subnet.snet-ep (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#227)
- resource.random_password.passwd (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#189)
- data source.azuread_group.adgrp (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#95)
- data source.azuread_service_principal.adspn (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#105)
- data source.azuread_user.adusr (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#100)
- data source.azurerm_client_config.current (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#113)
- data source.azurerm_private_endpoint_connection.private-ip1 (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#258)
- data source.azurerm_virtual_network.vnet01 (/usr/agent/azp/_work/1/s/amn-az-tfm-key-vault/main.tf#221)


## Example Scenario

Create key vault <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create key vault

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
  key_vault_suffix      = "kv"
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
  key_vault_name      = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.key_vault_suffix}-${local.environment_suffix}"
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

module "key_vault" {
  #checkov:skip=CKV2_AZURE_31: "Ensure VNET subnet is configured with a Network Security Group (NSG)"
  #checkov:skip=CKV_AZURE_41: "Ensure that the expiration date is set on all secrets"
  #checkov:skip=CKV_AZURE_109: "Ensure that key vault allows firewall rules settings"
  source                                     = "../"
  depends_on                                 = [module.rg]
  resource_group_name                        = local.resource_group_name
  key_vault_name                             = local.key_vault_name
  location                                   = var.location
  key_vault_sku_pricing_tier                 = var.key_vault_sku_pricing_tier
  enable_purge_protection                    = var.enable_purge_protection
  soft_delete_retention_days                 = var.soft_delete_retention_days
  self_key_permissions_access_policy         = var.self_key_permissions_access_policy
  self_secret_permissions_access_policy      = var.self_secret_permissions_access_policy
  self_certificate_permissions_access_policy = var.self_certificate_permissions_access_policy
  self_storage_permissions_access_policy     = var.self_storage_permissions_access_policy
  access_policies                            = var.access_policies
  secrets                                    = var.secrets
  enable_private_endpoint                    = var.enable_private_endpoint
  virtual_network_name                       = var.virtual_network_name
  private_subnet_address_prefix              = var.private_subnet_address_prefix
  public_network_access_enabled              = var.public_network_access_enabled
  enabled_for_template_deployment            = var.enabled_for_template_deployment
  enabled_for_disk_encryption                = var.enabled_for_disk_encryption
  enabled_for_deployment                     = var.enabled_for_deployment
  enable_rbac_authorization                  = var.enable_rbac_authorization
  tags                                       = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
#This example will create keyvault with private endpoint.
key_vault_sku_pricing_tier      = "premium"
location                        = "westus2"
public_network_access_enabled   = true
enable_purge_protection         = false
enabled_for_template_deployment = true
enabled_for_disk_encryption     = true
enable_rbac_authorization       = false
enabled_for_deployment          = true
soft_delete_retention_days      = 90

self_key_permissions_access_policy         = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Update"]
self_secret_permissions_access_policy      = ["Get", "List", "Delete", "Recover", "Backup", "Restore", "Set", "Purge"]
self_certificate_permissions_access_policy = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"]
self_storage_permissions_access_policy     = ["Get", "List"]


# Access policies for users, you can provide list of Azure AD users and set permissions.
# Make sure to use list of user principal names of Azure AD users.
access_policies = [
  # Commiting it out due to restricted conditions
  # {
  #   azure_ad_user_principal_names = ["usera@amnhealthcare.com", "user2@amnhealthcare.com"]
  #   key_permissions               = ["Get", "List"]
  #   secret_permissions            = ["Get", "List"]
  #   certificate_permissions       = ["Get", "List"]
  #   storage_permissions           = ["Get", "List"]
  # }

  # Access policies for AD Groups
  # to enable this feature, provide a list of Azure AD groups and set permissions as required.
  # {
  #   azure_ad_group_names    = ["ADGroupNamea", "ADGroupNameb"]
  #   key_permissions                  = ["Get","List"]
  #   secret_permissions               = ["Get","List"]
  #   certificate_permissions          = ["Get","List"]
  #   storage_permissions              = ["Get","List"]
  # },

  # Access policies for Azure AD Service Principlas
  # To enable this feature, provide a list of Azure AD SPN and set permissions as required.
  # {
  #   azure_ad_service_principal_names = ["azure-ad-dev-spA", "azure-ad-dev-spB"]
  #   key_permissions                  = ["Get","List"]
  #   secret_permissions               = ["Get","List"]
  #   certificate_permissions          = ["Get","List"]
  #   storage_permissions              = ["Get","List"]
  # }
]

# This will create secrets.
# When you Add `usernames` with empty password this module creates a strong random password
# use .tfvars file to manage the secrets as variables to avoid security issues.
secrets = {
  # Commiting it out due to restricted conditions
  # "message" = "AMNHealthCare"
  # "vmpass"  = ""
}

# This will create a `privatelink.vaultcore.azure.net` DNS zone by default.
# To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.
enable_private_endpoint       = false
virtual_network_name          = null
private_subnet_address_prefix = null
# existing_private_dns_zone     = "private-keyvault.amnhealthcare.com"

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