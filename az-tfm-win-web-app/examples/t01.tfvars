
location                   = "westus2"
os_type                    = "Windows"
sku_name                   = "S2"
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

create_app_service_plan = true

key_vault_sku_pricing_tier      = "premium"
public_network_access_enabled   = true
enable_purge_protection         = false
enabled_for_template_deployment = true
enabled_for_disk_encryption     = true
enable_rbac_authorization       = false
enabled_for_deployment          = true
soft_delete_retention_days      = 90

self_key_permissions_access_policy         = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Update"]
self_secret_permissions_access_policy      = ["Get", "List", "Delete", "Recover", "Backup", "Restore", "Set", "Purge"]
self_certificate_permissions_access_policy = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore"]
self_storage_permissions_access_policy     = ["Get", "List"]


# Access policies for users, you can provide list of Azure AD users and set permissions.
# Make sure to use list of user principal names of Azure AD users.
access_policies = []

# This will create secrets.
# When you Add `usernames` with empty password this module creates a strong random password
# use .tfvars file to manage the secrets as variables to avoid security issues.
secrets = {}

# This will create a `privatelink.vaultcore.azure.net` DNS zone by default.
# To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.
enable_private_endpoint       = false
virtual_network_name          = null
private_subnet_address_prefix = null

vnet_address_space      = ["10.85.0.0/24"]
create_ddos_plan        = false
ddos_plan_name          = ""
flow_timeout_in_minutes = 0

dns_servers                    = []
edge_zone                      = ""
firewall_subnet_address_prefix = ["10.85.0.0/25"]
gateway_subnet_address_prefix  = ["10.85.0.128/26"]
