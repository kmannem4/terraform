locals {
  db_parameters = { for parameter, value in lookup(var.db_parameters, var.db_engine, {}) : parameter => value if value != null /* object */ }

  firewall_rules = {
    for rule, value in var.db_firewall_rules : value.name => {
      start_ip_address = value.start_ip_address
      end_ip_address = value.end_ip_address
    }
  }
}


data "azurerm_key_vault" "KV" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "admin_username" {
  count        = var.use_keyvault_admin_username ? 1 : 0
  name         = var.admin_username_keyvault_secret_name
  key_vault_id = data.azurerm_key_vault.KV.id
}

data "azurerm_key_vault_secret" "admin_password" {
  count        = var.use_keyvault_admin_password ? 1 : 0
  name         = var.admin_password_keyvault_secret_name
  key_vault_id = data.azurerm_key_vault.KV.id
}


resource "azurerm_postgresql_flexible_server" "postgres" {
  name                    = var.db_server_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  version                 = var.db_engine_version
  administrator_login     = var.use_keyvault_admin_username ? data.azurerm_key_vault_secret.admin_username[0].value : var.db_username
  administrator_password  = var.use_keyvault_admin_password ? data.azurerm_key_vault_secret.admin_password[0].value : var.db_password
  create_mode             = var.db_create_mode
  sku_name                = var.db_server_sku
  storage_mb              = var.db_allocated_storage
  tags                    = var.tags

  # Backups
  backup_retention_days           = var.db_backup_retention_period
  geo_redundant_backup_enabled    = var.db_geo_backup_enabled

  zone                    = var.db_zone
  private_dns_zone_id     = var.db_private_dns_zone_id
  delegated_subnet_id     = var.db_private_dns_zone_id != null ? var.db_delegated_subnet_id : null

  source_server_id                    = var.db_create_source_id
  point_in_time_restore_time_in_utc   = var.db_create_mode == "PointInTimeRestore" && var.db_create_source_id != null ? var.db_restore_time : null
}

resource "azurerm_postgresql_flexible_server_database" "postgres" {
  count      = var.db_name != null ? 1 : 0
  name       = var.db_name
  server_id  = azurerm_postgresql_flexible_server.postgres.id
  collation  = var.db_collation
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
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres" {
  for_each  = local.db_parameters
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = each.value.value
}
