#general vars
location        = "westus2"
subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
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

#storage account
skuname                              = "Standard_LRS"
account_kind                         = "StorageV2"
public_network_access_enabled        = true
blob_soft_delete_retention_days      = 31
container_soft_delete_retention_days = 31
containers_list = [
  { name = "intelligence-hub", access_type = "private" },
  { name = "zipcodes", access_type = "private" }
]

#role assignment vars
role_definition_name = "Storage Account Backup Contributor"

#backup vault
identity = {
  type = "SystemAssigned"
}
datastore_type  = "VaultStore"
redundancy      = "LocallyRedundant"
backup_repeating_time_intervals        = null
operational_default_retention_duration = "P30D"
vault_default_retention_duration       = null
time_zone                              = null
priority                               = null
retention_rule                         = null
life_cycle                             = null
