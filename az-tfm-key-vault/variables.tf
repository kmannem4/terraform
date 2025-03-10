variable "resource_group_name" {
  description = "resource group name"
  default     = ""
}
variable "location" {
  description = "Location"
  default     = ""
}

variable "key_vault_name" {
  description = "Name of the key vault"
  default     = ""
}

variable "key_vault_sku_pricing_tier" {
  description = "SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Flag to allow Virtual Machines to retrieve certificates stored as secrets."
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Flag to allow Disk Encryption to retrieve secrets"
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Flag to allow Resource Manager to retrieve secrets"
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Flag to RBAC for authorization"
  default     = false
}

variable "enable_purge_protection" {
  description = "Is Purge Protection enabled"
  default     = false
}

variable "public_network_access_enabled" {
  description = "Is public network access enabled"
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Days for soft-deleted"
  default     = 90
}

variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "self_key_permissions_access_policy" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "self_secret_permissions_access_policy" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "self_certificate_permissions_access_policy" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "self_storage_permissions_access_policy" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 32
}

variable "certificate_contacts" {
  description = "Contact information to send notifications"
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []
}

variable "enable_private_endpoint" {
  description = "Private Endpoint to Azure Container Registry"
  default     = false
}

variable "virtual_network_name" {
  description = "virtual network"
  default     = ""
}

variable "existing_vnet_id" {
  description = "Existing Virtual network"
  default     = null
}

variable "existing_subnet_id" {
  description = "Existing subnet"
  default     = null
}

variable "existing_private_dns_zone" {
  description = "Existing private DNS zone"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "address prefix of the subnet for private endpoints"
  default     = null
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}
