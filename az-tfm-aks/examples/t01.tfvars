location                = "westus2"
vnet_address_space      = ["10.81.0.0/26"]
network_plugin          = "azure"
network_policy          = "calico"
network_plugin_mode     = "overlay"
kubernetes_version      = "1.29.2"
log_analytics_workspace_id = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"
subnets = {
  mgnt_subnet1 = {
    subnet_name           = "kube-subnet"
    subnet_address_prefix = ["10.81.0.0/27"]
  }
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
