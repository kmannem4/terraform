rgname   = "testrg-dev"
location = "West US2"
storagename = "testsa-dev"
subnets = {
    pvt_subnet = {
        subnet_name                 = "snet-pvt"
        subnet_address_prefix       = ["10.1.4.0/27"]
        service_endpoints           = ["Microsoft.Storage", "Microsoft.KeyVault"]
        /**delegation = {
            name                = "delegation"
            service_delegation  = {
                name    = "Microsoft.DBforPostgreSQL/flexibleServers"
                actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
        }**/
        nsg_inbound_rules = [
            //["AllowBastionSSHInbound", "100", "Inbound", "Allow", "Tcp", "22", "10.103.0.32/27", "*"],
            //["AllowBitBucketSSHInbound", "200", "Inbound", "Allow", "Tcp", "22", "34.199.54.113", "*"],
            //["AllowBitBucketSSHInbound", "200", "Inbound", "Allow", "Tcp", "22", "\"34.199.54.113\",\"34.232.25.90\",\"34.232.119.183\",\"34.236.25.177\",\"35.171.175.212\",\"52.54.90.98\",\"52.202.195.162\",\"52.203.14.55\",\"52.204.96.37\",\"34.218.156.209\",\"34.218.168.212\",\"52.41.219.63\",\"35.155.178.254\",\"35.160.177.10\",\"34.216.18.129\",\"3.216.235.48\",\"34.231.96.243\",\"44.199.3.254\",\"174.129.205.191\",\"44.199.127.226\",\"44.199.45.64\",\"3.221.151.112\",\"52.205.184.192\",\"52.72.137.240\"", "*"],
        ]

        nsg_outbound_rules = [
        ]
    },
  pvt_subnet2 = {
    subnet_name           = "snet2-pvt"
    subnet_address_prefix = ["10.1.4.32/27"]
    service_endpoints     = ["Microsoft.Storage", "Microsoft.KeyVault"]
    /**delegation = {
      name = "delegation"
      service_delegation = {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }**/
    nsg_inbound_rules = [
    ]
    nsg_outbound_rules = [
    ]
  }
}
