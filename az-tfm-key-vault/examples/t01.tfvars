#This example will create keyvault with private endpoint.
key_vault_sku_pricing_tier      = "premium"
location                        = "westus2"
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
access_policies = [
  # Commiting it out due to restricted conditions
  # {
  #   azure_ad_user_principal_names = ["usera@amnhealthcare.com", "user2@amnhealthcare.com"]
  #   key_permissions               = ["Get", "List"]
  #   secret_permissions            = ["Get", "List"]
  #   certificate_permissions       = ["Get", "List"]
  #   storage_permissions           = ["Get", "List"]
  # }

  # Access policies for AD Groups
  # to enable this feature, provide a list of Azure AD groups and set permissions as required.
  # {
  #   azure_ad_group_names    = ["ADGroupNamea", "ADGroupNameb"]
  #   key_permissions                  = ["Get","List"]
  #   secret_permissions               = ["Get","List"]
  #   certificate_permissions          = ["Get","List"]
  #   storage_permissions              = ["Get","List"]
  # },

  # Access policies for Azure AD Service Principlas
  # To enable this feature, provide a list of Azure AD SPN and set permissions as required.
  # {
  #   azure_ad_service_principal_names = ["azure-ad-dev-spA", "azure-ad-dev-spB"]
  #   key_permissions                  = ["Get","List"]
  #   secret_permissions               = ["Get","List"]
  #   certificate_permissions          = ["Get","List"]
  #   storage_permissions              = ["Get","List"]
  # }
]

# This will create secrets.
# When you Add `usernames` with empty password this module creates a strong random password
# use .tfvars file to manage the secrets as variables to avoid security issues.
secrets = {
  # Commiting it out due to restricted conditions
  # "message" = "AMNHealthCare"
  # "vmpass"  = ""
}

# This will create a `privatelink.vaultcore.azure.net` DNS zone by default.
# To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.
enable_private_endpoint       = false
virtual_network_name          = null
private_subnet_address_prefix = null
# existing_private_dns_zone     = "private-keyvault.amnhealthcare.com"

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

