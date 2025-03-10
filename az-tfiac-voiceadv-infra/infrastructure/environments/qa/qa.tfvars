rgname             = "co-wus2-voiceadv-rg-q01"
location           = "West US2"
vnetname           = "co-wus2-voiceadv-vnet-q01"
vnet_address_space = ["10.100.2.0/26"]
vm_base_name       = "co-wus2-voiceadv-docker-vm"
initial_index      = 1
vm_count           = 3
vm_suffix          = "-q01"

subnets = {
  subnet_vm = {
    subnet_name           = "co-wus2-voiceadv-subnet-vm-q01"
    subnet_address_prefix = ["10.100.2.0/27"]
    service_endpoints     = ["Microsoft.Storage"]
    nsg_inbound_rules = [
      ["AllowBastionSSHInbound", "100", "Inbound", "Allow", "Tcp", "22", "10.103.0.32/27", "*"],
      ["AllowBitBucketSSHInbound", "200", "Inbound", "Allow", "Tcp", "22", "34.199.54.113", "*"],
      ["AllowVoxBRCKTCPInbound", "210", "Inbound", "Allow", "Tcp", "5060", "216.82.224.202", "*"],
      ["AllowVoxBRCKTCP2Inbound", "220", "Inbound", "Allow", "Tcp", "5060", "216.82.225.202", "*"],
      ["AllowVoxBRCKUDPInbound", "230", "Inbound", "Allow", "Udp", "5060", "216.82.224.202", "*"],
      ["AllowVoxBRCKUDP2Inbound", "240", "Inbound", "Allow", "Udp", "5060", "216.82.225.202", "*"],
      ["AllowVoxBRCKUDP3nbound", "250", "Inbound", "Allow", "Udp", "1024-64000", "216.82.236.0/25", "*"],
      ["AllowVoxBRCKUDP4Inbound", "260", "Inbound", "Allow", "Udp", "1024-64000", "216.82.237.0/25", "*"],
      ["AllowImpervaWAF1Inbound", "300", "Inbound", "Allow", "Tcp", "443", "216.82.225.202", "*"],
      ["AllowImpervaWAF2Inbound", "310", "Inbound", "Allow", "Tcp", "443", "199.83.128.0/21", "*"],
      ["AllowImpervaWAF3Inbound", "320", "Inbound", "Allow", "Tcp", "443", "198.143.32.0/19", "*"],
      ["AllowImpervaWAF4Inbound", "330", "Inbound", "Allow", "Tcp", "443", "149.126.72.0/21", "*"],
      ["AllowImpervaWAF5Inbound", "340", "Inbound", "Allow", "Tcp", "443", "103.28.248.0/22", "*"],
      ["AllowImpervaWAF6Inbound", "350", "Inbound", "Allow", "Tcp", "443", "45.64.64.0/22", "*"],
      ["AllowImpervaWAF7Inbound", "360", "Inbound", "Allow", "Tcp", "443", "185.11.124.0/22", "*"],
      ["AllowImpervaWAF8Inbound", "370", "Inbound", "Allow", "Tcp", "443", "192.230.64.0/18", "*"],
      ["AllowImpervaWAF9Inbound", "380", "Inbound", "Allow", "Tcp", "443", "107.154.0.0/16", "*"],
      ["AllowImpervaWAF10Inbound", "390", "Inbound", "Allow", "Tcp", "443", "45.60.0.0/16", "*"],
      ["AllowImpervaWAF11Inbound", "400", "Inbound", "Allow", "Tcp", "443", "45.223.0.0/16", "*"],
      ["AllowImpervaWAF12Inbound", "410", "Inbound", "Allow", "Tcp", "443", "131.125.128.0/17", "*"]



    ]
    nsg_outbound_rules = [
    ]
  },
  subnet_pg = {
    subnet_name           = "co-wus2-voiceadv-subnet-pg-q01"
    subnet_address_prefix = ["10.100.2.32/28"]
    service_endpoints     = ["Microsoft.Storage"]
    delegation = {
      name = "delegation"
      service_delegation = {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    nsg_inbound_rules = [
    ]
    nsg_outbound_rules = [
    ]
  }
}

vmname = {
  Vm_docker1 = {
    vm_name = "co-wus2-voiceadv-docker-vm1-q01"
  },
  Vm_docker2 = {
    vm_name = "co-wus2-voiceadv-docker-vm2-q01"
  },
}
data_disks = [
  {
    name                 = "co-wus2-voiceadv-docker-disk1-q01"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
    caching              = "ReadWrite"

  },

]
admin_password                      = "Admin@123456"
environment                         = "qa"
ssh_key_name                        = "co-wus2-voiceadv-sshkey-vm-d01"
basthost_publicip                   = "co-wus2-voiceadv-publicip-q01"
bastionhost_name                    = "co-wus2-voiceadv-basthost-q01"
keyvault_id                         = "/subscriptions/de714383-62fd-47f3-a8d5-440d93cd87db/resourceGroups/co-wus2-voiceadv-rg-q01/providers/Microsoft.KeyVault/vaults/co-wus2-voiceadv-kv-q01"
use_keyvault_admin_username         = true
admin_username_keyvault_secret_name = "postgres"

use_keyvault_admin_password         = true
admin_password_keyvault_secret_name = "postgres"
db_servers_name = {
  pg1 = {
    db_server_name = "co-wus2-voiceadv-sql-q01"
  },
  pg2 = {
    db_server_name = "co-wus2-voiceadv-sql1-q01"
  },
  pg3 = {
    db_server_name = "co-wus2-voiceadv-sqlsandbox-q01"
  }
}

db_names = [
  "Voicescreener",
  "harqen_telephony"
]
db_engine_version          = "12"
keyvault_name              = "co-wus2-voiceadv-kv-q01"
admin_username_secret_name = "pgadmin"
admin_password_secret_name = "pgadmin"
db_username                = "pgadmin"
db_password                = "Voice@qa"
db_private_dns_zone_id     = "co-wus2-voiceadv-sql-q01.private.postgres.database.azure.com"
db_private_dns_zone_id1    = "co-wus2-voiceadv-sql1-q01.private.postgres.database.azure.com"
db_private_dns_zone_id2    = "co-wus2-voiceadv-sqlsand-q01.private.postgres.database.azure.com"

postgresql_private_endpoint = "co-wus2-voiceadv-pe-q01"

subscription_id       = "de714383-62fd-47f3-a8d5-440d93cd87db"
source_address_prefix = "10.103.0.32/27"

instances_count   = "3"
workspace_id      = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"
application_type  = "web"
app_insights_name = "co-wus2-voiceadv-ai-q01"
