module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "cosmons_db_account" {
  depends_on          = [module.rg]
  source              = "../"
  resource_group_name = local.resource_group_name
  # version = "1.0.0"

  # By default, this module will not create a resource group
  # provide a name to use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 
  location = var.location

  cosmos_db_account_name = var.cosmos_db_account_name
  kind                   = var.kind
  offer_type             = var.offer_type

  # Enable Analytical Storage option for this Cosmos DB account.
  analytical_storage_enabled = var.analytical_storage_enabled
  # The schema type of the Analytical Storage for this Cosmos DB account.
  analytical_storage_schema_type = var.analytical_storage_schema_type

  # The total throughput limit imposed on this Cosmos DB account (RU/s).
  total_throughput_limit_capacity = var.total_throughput_limit_capacity

  # Whether or not public network access is allowed for this CosmosDB account.
  public_network_access_enabled = var.public_network_access_enabled

  # Enable automatic failover for this Cosmos DB account.
  enable_automatic_failover = var.enable_automatic_failover

  # Enable multiple write locations for this Cosmos DB account.
  enable_multiple_write_locations = var.enable_multiple_write_locations

  # Is write operations on metadata resources (databases, containers, throughput) via account keys enabled?
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled

  # Whether Cosmos DB is zone redundant or not
  is_zone_redundant = var.is_zone_redundant

  # Adding TAG's to your Azure resources (Required)
  tags = var.tags

  # Enable the Free Tier pricing option for this Cosmos DB account.
  enable_free_tier = var.enable_free_tier

  # The Type of Managed Identity assigned to this Cosmos account.
  managed_identity_type = var.managed_identity_type
  # Specifies a list of User Assigned Managed Identity IDs to be assigned to this Cosmos Account.
  managed_identity_ids = var.managed_identity_ids

  # Configures the capabilities to be enabled for this Cosmos DB account
  cosmosdb_account_capabilities = var.cosmosdb_account_capabilities

  # Used to define the consistency policy for this CosmosDB account
  # The Consistency Level to use for this CosmosDB Account
  cosmosdb_account_consistency_policy_consistency_level = var.cosmosdb_account_consistency_policy_consistency_level
  # When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. 
  cosmosdb_account_consistency_policy_max_interval_in_seconds = var.cosmosdb_account_consistency_policy_max_interval_in_seconds
  # When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated.
  cosmosdb_account_consistency_policy_max_staleness_prefix = var.cosmosdb_account_consistency_policy_max_staleness_prefix

  # The creation mode for the CosmosDB Account.
  create_mode = var.create_mode

  # The default identity for accessing Key Vault.
  default_identity_type = var.default_identity_type

  # CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IPs for a given database account. IP addresses/ranges must be comma separated and must not contain any spaces.
  ip_range_filter = var.ip_range_filter

  # Enables virtual network filtering for this Cosmos DB account.
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled

  # A versionless Key Vault Key ID for CMK encryption.
  is_key_vault_cmk_encryption_in_use             = var.is_key_vault_cmk_encryption_in_use
  cosmosdb_account_key_vault_name                = var.cosmosdb_account_key_vault_name
  cosmosdb_account_key_vault_resource_group_name = var.cosmosdb_account_key_vault_resource_group_name
  cosmosdb_account_key_vault_key_name            = var.cosmosdb_account_key_vault_key_name

  # Configures the virtual network subnets allowed to access this Cosmos DB account
  is_virtual_network_subnets_allowed = var.is_virtual_network_subnets_allowed
  # if is_virtual_network_subnets_allowed is true then user need to provide a list of subnets with it's details such as ignore_missing_vnet_service_endpoint, subnet name, vnet and rg and 
  virtual_network_subnets = var.virtual_network_subnets

  # Configures the backup for this Cosmos DB account
  cosmosdb_account_backup = var.cosmosdb_account_backup

  # If Azure services can bypass ACLs.
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services

  # The list of resource Ids for Network Acl Bypass for this Cosmos DB account.
  network_acl_bypass_ids = var.network_acl_bypass_ids

  # Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Defaults to false. Can be set only when using the SQL API.
  local_authentication_disabled = var.local_authentication_disabled

  # If we can enable Restore on cosmos DB account.
  enable_restore = var.enable_restore

  # If enable_restore is true, restore block needs to set
  restore = var.restore

  # A cors_rule block.
  cors_rule = var.cors_rule

  # CosmosDB SQL Database variables
  cosmosdb_sql_database_variables = var.cosmosdb_sql_database_variables
}
