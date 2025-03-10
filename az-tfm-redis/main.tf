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