location = "westus2"
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

subnets = {
  mgnt_subnet1 = {
    subnet_name           = "snet-management1"
    subnet_address_prefix = ["10.0.1.0/24"]
  }
}
sku = {
  name     = "Standard_v2"
  tier     = "Standard_v2"
  capacity = 1
}
backend_address_pools = [
  {
    name = "appgw-testgateway-wus2-bapool01"
  }
]

backend_http_settings = [
  {
    name                                = "appgw-testgateway-wus2-be-http-set1"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    enable_https                        = false
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    connection_draining = {
      enable_connection_draining = true
      drain_timeout_sec          = 300
    }
  }
]

http_listeners = [
  {
    name                 = "appgw-testgateway-wus2-be-htln01"
    ssl_certificate_name = null
    firewall_policy_id   = null
    ssl_profile_name     = null
  }
]

request_routing_rules = [
  {
    name                       = "appgw-testgateway-wus2-be-rqrt"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "appgw-testgateway-wus2-be-htln01"
    backend_address_pool_name  = "appgw-testgateway-wus2-bapool01"
    backend_http_settings_name = "appgw-testgateway-wus2-be-http-set1"
  }
]