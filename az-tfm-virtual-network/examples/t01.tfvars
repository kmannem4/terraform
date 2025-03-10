create_network_watcher  = false
location                = "westus2"
vnetwork_name           = "co-wus2-tftest-vnet-t01"
vnet_address_space      = ["10.0.0.0/16"]
create_ddos_plan        = false
ddos_plan_name          = ""
flow_timeout_in_minutes = 0
subnets = {
  mgnt_subnet1 = {
    subnet_name           = "snet-management1"
    subnet_address_prefix = ["10.0.1.0/24"]
  }
  mgnt_subnet2 = {
    subnet_name           = "snet-management2"
    subnet_address_prefix = ["10.0.2.0/24"]
  }
}

dns_servers                    = []
edge_zone                      = ""
firewall_subnet_address_prefix = ["10.0.3.0/24"]
gateway_subnet_address_prefix  = ["10.0.4.0/24"]
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
