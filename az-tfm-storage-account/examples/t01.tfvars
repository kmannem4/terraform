location                             = "westus2"
storage_account_name                 = "cowus2aoshrdsa13t01"
skuname                              = "Standard_LRS"
public_network_access_enabled        = true
enable_versioning                    = false
blob_soft_delete_retention_days      = 31
container_soft_delete_retention_days = 31
enable_advanced_threat_protection    = false
allow_nested_items_to_be_public      = false
containers_list = [
  { name = "intelligence-hub", access_type = "private" },
  { name = "zipcodes", access_type = "private" }
]
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