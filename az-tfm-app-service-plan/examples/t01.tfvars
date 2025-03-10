create_app_service_plan    = true
location                   = "westus2"
app_service_plan_name      = "amn-wus2-tftest-aspl-t01"
os_type                    = "Linux"
sku_name                   = "P1v2"
log_analytics_workspace_id = null
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
