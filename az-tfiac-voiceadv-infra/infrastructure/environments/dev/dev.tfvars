rgname             = "co-wus2-voiceadv-rg-d01"
location           = "West US2"
vnetname           = "co-wus2-voiceadv-vnet-d01"
vnet_address_space = ["10.100.2.64/26"]
vm_base_name       = "co-wus2-voiceadv-docker-vm"
initial_index      = 1
vm_count           = 2
vm_suffix          = "d"

subnets = {
  subnet_vm = {
    subnet_name           = "co-wus2-voiceadv-subnet-vm-d01"
    subnet_address_prefix = ["10.100.2.64/27"]
    service_endpoints     = ["Microsoft.Storage"]
    nsg_inbound_rules = [
      ["AllowBastionSSHInbound", "100", "Inbound", "Allow", "Tcp", "22", "10.103.0.32/27", "*"],
      ["AllowBitBucketSSHInbound", "200", "Inbound", "Allow", "Tcp", "22", "34.199.54.113", "*"],
      ["AllowBitBucketSSH1Inbound", "270", "Inbound", "Allow", "Tcp", "22", "34.232.25.90", "*"],
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
      ["AllowImpervaWAF12Inbound", "410", "Inbound", "Allow", "Tcp", "443", "131.125.128.0/17", "*"],
      ["AllowBitBucketSSH2Inbound", "280", "Inbound", "Allow", "Tcp", "22", "34.232.119.183", "*"],
      ["AllowBitBucketSSH3Inbound", "290", "Inbound", "Allow", "Tcp", "22", "34.236.25.177", "*"],
      ["AllowBitBucketSSH4Inbound", "500", "Inbound", "Allow", "Tcp", "22", "35.171.175.212", "*"],
      ["AllowBitBucketSSH5Inbound", "510", "Inbound", "Allow", "Tcp", "22", "52.54.90.98", "*"],
      ["AllowBitBucketSSH6Inbound", "520", "Inbound", "Allow", "Tcp", "22", "52.202.195.162", "*"],
      ["AllowBitBucketSSH7Inbound", "530", "Inbound", "Allow", "Tcp", "22", "52.203.14.55", "*"],
      ["AllowBitBucketSSH8Inbound", "540", "Inbound", "Allow", "Tcp", "22", "52.204.96.37", "*"],
      ["AllowBitBucketSSH9Inbound", "550", "Inbound", "Allow", "Tcp", "22", "34.218.156.209", "*"],
      ["AllowBitBucketSSH10Inbound", "560", "Inbound", "Allow", "Tcp", "22", "34.218.168.212", "*"],
      ["AllowBitBucketSSH11Inbound", "570", "Inbound", "Allow", "Tcp", "22", "52.41.219.63", "*"],
      ["AllowBitBucketSSH12Inbound", "580", "Inbound", "Allow", "Tcp", "22", "35.155.178.254", "*"],
      ["AllowBitBucketSSH13Inbound", "590", "Inbound", "Allow", "Tcp", "22", "35.160.177.10", "*"],
      ["AllowBitBucketSSH14Inbound", "600", "Inbound", "Allow", "Tcp", "22", "34.216.18.129", "*"],
      ["AllowBitBucketSSH15Inbound", "610", "Inbound", "Allow", "Tcp", "22", "3.216.235.48", "*"],
      ["AllowBitBucketSSH16Inbound", "620", "Inbound", "Allow", "Tcp", "22", "34.231.96.243", "*"],
      ["AllowBitBucketSSH17Inbound", "630", "Inbound", "Allow", "Tcp", "22", "44.199.3.254", "*"],
      ["AllowBitBucketSSH18Inbound", "640", "Inbound", "Allow", "Tcp", "22", "174.129.205.191", "*"],
      ["AllowBitBucketSSH19Inbound", "650", "Inbound", "Allow", "Tcp", "22", "44.199.127.226", "*"],
      ["AllowBitBucketSSH20Inbound", "660", "Inbound", "Allow", "Tcp", "22", "44.199.45.64", "*"],
      ["AllowBitBucketSSH21Inbound", "670", "Inbound", "Allow", "Tcp", "22", "3.221.151.112", "*"],
      ["AllowBitBucketSSH22Inbound", "680", "Inbound", "Allow", "Tcp", "22", "52.205.184.192", "*"],
      ["AllowBitBucketSSH23Inbound", "690", "Inbound", "Allow", "Tcp", "22", "52.72.137.240", "*"]
    ]
    nsg_outbound_rules = [
    ]
  },
  subnet_pg = {
    subnet_name           = "co-wus2-voiceadv-subnet-pg-d01"
    subnet_address_prefix = ["10.100.2.96/28"]
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
    vm_name = "co-wus2-voiceadv-docker-vm1-d01"
  },
  Vm_docker2 = {
    vm_name = "co-wus2-voiceadv-docker-vm2-d01"
  },
}
data_disks = [
  {
    name                 = "co-wus2-voiceadv-docker-disk1-d01"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
    caching              = "ReadWrite"

  },

]
admin_password                      = "Admin@123456"
environment                         = "dev"
ssh_key_name                        = "co-wus2-voiceadv-sshkey-vm-d01"
basthost_publicip                   = "co-wus2-voiceadv-publicip-d01"
bastionhost_name                    = "co-wus2-voiceadv-basthost-d01"
keyvault_id                         = "/subscriptions/de714383-62fd-47f3-a8d5-440d93cd87db/resourceGroups/co-wus2-voiceadv-rg-d01/providers/Microsoft.KeyVault/vaults/co-wus2-voiceadv-kv-d01"
use_keyvault_admin_username         = true
admin_username_keyvault_secret_name = "postgres"

use_keyvault_admin_password         = true
admin_password_keyvault_secret_name = "postgres"
db_servers_name = {
  pg1 = {
    db_server_name = "cowus2voiceadvpsqld01"
  },
  pg2 = {
    db_server_name = "cowus2voiceadvpsqld01"
  }  
}

db_names = [
  "Voicescreener",
  "harqen_telephony"
]
db_engine_version          = "12"
keyvault_name              = "co-wus2-voiceadv-kv-d01"
admin_username_secret_name = "pgadmin"
admin_password_secret_name = "pgadmin"
db_username                = "pgadmin"
db_password                = "Voice@qa"
db_private_dns_zone_id     = "co-wus2-voiceadv-sql-d01.private.postgres.database.azure.com"
db_private_dns_zone_id1    = "co-wus2-voiceadv-sql1-d01.private.postgres.database.azure.com"


postgresql_private_endpoint = "co-wus2-voiceadv-pe-q01"

subscription_id       = "de714383-62fd-47f3-a8d5-440d93cd87db"
source_address_prefix = "10.103.0.32/27"

instances_count   = "3"
workspace_id      = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"
application_type  = "web"
app_insights_name = "co-wus2-voiceadv-ai-d01"
storage_account_name= "cowus2voiceadvprmsad01"
sa_container = "dev-premsa-nfs"
sa_privateendpoint = "cowus2voiceadvpersapepd01"
privatedns_count = "2"