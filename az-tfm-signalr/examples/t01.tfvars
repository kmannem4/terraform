location                             = "westus2"
allowed_origins                      = ["*"] 
connectivity_logs_enabled            = true
messaging_logs_enabled               = true
live_trace_enabled                   = true
service_mode                         = "Default"
public_network_access_enabled        = true
network_acl_default_action           = "Deny" 
public_network_allowed_request_types = ["ServerConnection","ClientConnection","RESTAPI","Trace"]
sku                                  = {
                                         name     = "Standard_S1"
                                         capacity = 1
                                       }
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