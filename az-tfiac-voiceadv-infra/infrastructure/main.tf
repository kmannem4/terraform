terraform {
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm" # https://registry.terraform.io/providers/hashicorp/azurerm/latest

    }
  }
}
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
locals {
  db_parameters = { for parameter, value in lookup(var.db_parameters, var.db_engine, {}) : parameter => value if value != null /* object */ }

  firewall_rules = {
    for rule, value in var.db_firewall_rules : value.name => {
      start_ip_address = value.start_ip_address
      end_ip_address = value.end_ip_address
    }
  }
}
module "ResourceGroup" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source              = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-resourcegroup?ref=tags/v1.0.0"
  resource_group_name = var.rgname
  location            = var.location

  tags = {
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    application = "Voice Advantage"
    product     = "Silversheet"
    owner       = "cloud.engineers@amnhealthcare.com"
    managed-by  = "cloud.engineers@amnhealthcare.com"
  }
}



module "vnet" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source                 = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-virtual-network?ref=tags/v1.0.0"
  create_resource_group  = false
  resource_group_name    = module.ResourceGroup.resource_group_name
  vnetwork_name          = var.vnetname
  location               = var.location
  vnet_address_space     = var.vnet_address_space
  create_network_watcher = false
  subnets                = var.subnets

  tags = {
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    application = "Voice Advantage"
    product     = "Silversheet"
  }
  depends_on = [module.ResourceGroup]

}

## Virtual Machine #
module "linux-virtual-machine" {
  count = var.vm_count

  
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-virtual-machine?ref=331f0b1db65a7238763b010d51e6640690cc4f7c"
  #for_each                       = local.vm_instances
  resource_group_name  = module.ResourceGroup.resource_group_name
  location             = var.location
  virtual_network_name = var.vnetname
  subnet_name          = var.subnets.subnet_vm.subnet_name
  #instances_count                 = 3
  #virtual_machine_name            = each.value.vm_name
  virtual_machine_name               = "amnwus2vadvvm${var.vm_suffix}${count.index}"
  os_flavor                          = "linux"
  linux_distribution_name            = "ubuntu2004"
  virtual_machine_size               = "Standard_D8as_v5"
  generate_admin_ssh_key             = false
  admin_username                     = var.admin_username
  admin_password                     = var.admin_pass
  disable_password_authentication    = false
  enable_public_ip_address           = true
  existing_network_security_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/networkSecurityGroups/nsg_subnet_vm_in"
  

  data_disks = var.data_disks
  tags = {
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    application = "Voice Advantage"
    product     = "Silversheet"
  }
  depends_on = [module.ResourceGroup,module.vnet.azurerm_network_security_group]
}



module "storageaccount" {
  #checkov:skip=CKV2_AZURE_21:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-storage-account?ref=75962c70de14bcf1b75de234099482f6a881c4a7"
  storage_account_name = var.storage_account_name
  resource_group_name =  module.ResourceGroup.resource_group_name
  location = var.location
  account_kind = "BlockBlobStorage"
  skuname = "Premium_LRS"
  public_network_access_enabled = false
  allow_nested_items_to_be_public = false

  tags = {
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    application = "Voice Advantage"
    product     = "Silversheet"
  }
   
}
# Create a container inside SA
resource "azurerm_storage_container" "storagecontainer" {
  #checkov:skip=CKV2_AZURE_21:checkov bug skipping
  name = var.sa_container
  storage_account_name =  module.storageaccount.storage_account_name
  container_access_type = "private" 
}

# Create a private endpoint for the storage account
resource "azurerm_private_endpoint" "sa_endpoint" {
  name                = var.sa_privateendpoint
  location            = var.location
  resource_group_name = module.ResourceGroup.resource_group_name
  subnet_id           = module.vnet.subnet_ids[0]

  private_service_connection {
    name                           = var.sa_privateendpoint
    private_connection_resource_id = module.storageaccount.storage_account_id
    is_manual_connection           = false
  }
}

### User Assigned Identity for postgress ###

resource "azurerm_user_assigned_identity" "pgsql" {
  name = "${var.db_servers_name.pg1.db_server_name}-db-mi"
  resource_group_name = var.rgname
  location = var.location
   tags = {
    application = "Infrastructure"
    product     = "Infrastructure"
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    managed-by  = "cloud.engineers@amnhealthcare.com"
    owner       = "cloud.engineers@amnhealthcare.com"
  }
}

## KV creation 
resource "azurerm_key_vault" "KV" {
  name                            = var.keyvault_name
  location                        = var.location
  resource_group_name             = module.ResourceGroup.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  enable_rbac_authorization       = true
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = false
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  public_network_access_enabled   = false
  tags = {
    application = "Infrastructure"
    product     = "Infrastructure"
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    managed-by  = "cloud.engineers@amnhealthcare.com"
    owner       = "cloud.engineers@amnhealthcare.com"
  }
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_private_endpoint" "kv_endpt" {
  name                = lower("${azurerm_key_vault.KV.name}-ep")
  location            = var.location
  resource_group_name = module.ResourceGroup.resource_group_name
  subnet_id           = module.vnet.subnet_ids[0]

  private_service_connection {
    name                           = "${azurerm_key_vault.KV.name}-pl"
    private_connection_resource_id = azurerm_key_vault.KV.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
}
resource "azurerm_key_vault_secret" "kvsecret" {
  name         = "postgres"
  value        = "postgres"
  key_vault_id = azurerm_key_vault.KV.id
  content_type = "text/plain"
  expiration_date = "2024-12-31T23:59:59Z"
}

resource "azurerm_key_vault_access_policy" "kv" {
  key_vault_id    = azurerm_key_vault.KV.id
  tenant_id       = data.azurerm_client_config.current.tenant_id
  object_id       = azurerm_user_assigned_identity.pgsql.principal_id
  secret_permissions = ["Get", "List", "Delete"]  
}


resource "azurerm_private_dns_zone" "postgres_dns_zone" {
  name                = var.db_private_dns_zone_id
  resource_group_name = module.ResourceGroup.resource_group_name
  depends_on          = [module.ResourceGroup]
}

resource "azurerm_postgresql_flexible_server" "pgsql" {
  #checkov:skip=CKV_AZURE_136:checkov bug skipping
  name                             = var.db_servers_name.pg1.db_server_name
  location                         =var.location
  resource_group_name              = var.rgname
  sku_name                         = "GP_Standard_D4ds_v4"
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns_zone.id
  administrator_login              = var.use_keyvault_admin_username ? azurerm_key_vault_secret.kvsecret.name : var.db_username
  administrator_password           = var.use_keyvault_admin_password ? azurerm_key_vault_secret.kvsecret.value : var.db_password
  create_mode                      = var.db_create_mode
  storage_mb                       = var.db_allocated_storage
  tags = {
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    application = "Voice Advantage"
    product     = "Silversheet"
    owner       = "cloud.engineers@amnhealthcare.com"
    managed-by  = "cloud.engineers@amnhealthcare.com"
  }
  backup_retention_days            = 35
  geo_redundant_backup_enabled     = var.geo_redundant_backup_enabled
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.pgsql.id]
  }
  depends_on = [module.vnet]
}

resource "azurerm_postgresql_flexible_server_database" "postgres" {
  count      = var.db_servers_name.pg1.db_server_name != null ? 1 : 0
  name       = var.db_servers_name.pg1.db_server_name
  server_id  = azurerm_postgresql_flexible_server.pgsql.id
  collation  = "en_US.utf8"
  charset    = var.db_charset
  
  timeouts {
    create = var.db_timeouts.create
    delete = var.db_timeouts.delete
    read   = var.db_timeouts.read
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall" {
  for_each         = local.firewall_rules
  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.pgsql.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres" {
  for_each  = local.db_parameters
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.pgsql.id
  value     = each.value.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "example_link" {
  name                  = azurerm_private_dns_zone.postgres_dns_zone.name
  resource_group_name   = module.ResourceGroup.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone.name
  virtual_network_id    = module.vnet.virtual_network_id
  tags = {
    charge-to   = "101-71200-5000-9500"
    environment = var.environment
    application = "Voice Advantage"
    product     = "Silversheet"
  }
  depends_on = [module.ResourceGroup]
}
