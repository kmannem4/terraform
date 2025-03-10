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
