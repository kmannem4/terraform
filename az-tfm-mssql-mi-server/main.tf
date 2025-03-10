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
