variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to send diagnostic logs to."
  default     = null
  type        = string
}

variable "location" {
  description = "Function App location"
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
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

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "enable_private_endpoint" {
  description = "Private Endpoint to Azure Container Registry"
  default     = false
}

variable "virtual_network_name" {
  description = "virtual network"
  default     = ""
}

# variable "existing_private_dns_zone" {
#   description = "Existing private DNS zone"
#   default     = null
# }

variable "private_subnet_address_prefix" {
  description = "address prefix of the subnet for private endpoints"
  default     = null
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.0.0.0/16"]
}

variable "create_ddos_plan" {
  description = "Create an ddos plan - Default is false"
  default     = false
}

variable "ddos_plan_name" {
  description = "The name of AzureNetwork DDoS Protection Plan"
  default     = "azureddosplan01"
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  type        = list(string)
  default     = []
}

variable "create_network_watcher" {
  description = "Controls if Network Watcher resources should be created for the Azure subscription"
  default     = false
}

variable "gateway_subnet_address_prefix" {
  description = "The address prefix to use for the gateway subnet"
  default     = null
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix to use for the Firewall subnet"
  default     = null
}

variable "edge_zone" {
  description = "The edge zone to use for the virtual network"
  default     = ""
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes"
  default     = 0
}

variable "skuname" {
  description = "The SKUs supported by Microsoft Azure Storage. Valid options are Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS, Standard_RAGRS, Standard_RAGZRS, Standard_ZRS"
  default     = "Standard_RAGRS"
  type        = string
}

variable "account_kind" {
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "StorageV2"
  type        = string
}

variable "container_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
  type        = number
}

variable "blob_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between `1` and `365` days. Defaults to `7`"
  default     = 7
  type        = number
}

variable "containers_list" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, access_type = string }))
  default     = []
}


variable "create_app_service_plan" {
  description = "App Service Plan to create"
  default     = false
}

variable "os_type" {
  description = "The O/S type for the App Services to be hosted in this plan. Possible values include `Windows`, `Linux`, and `WindowsContainer`."
  type        = string

  validation {
    condition     = try(contains(["Windows", "Linux", "WindowsContainer"], var.os_type), true)
    error_message = "The `os_type` value must be valid. Possible values are `Windows`, `Linux`, and `WindowsContainer`."
  }
}

variable "sku_name" {
  description = "The SKU for the plan. Possible values include B1, B2, B3, D1, F1, FREE, I1, I2, I3, I1v2, I2v2, I3v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, S1, S2, S3, SHARED, Y1, EP1, EP2, EP3, WS1, WS2, and WS3."
  type        = string

  validation {
    condition     = try(contains(["B1", "B2", "B3", "D1", "F1", "FREE", "I1", "I2", "I3", "I1v2", "I2v2", "I3v2", "P1v2", "P2v2", "P3v2", "P0v3", "P1v3", "P2v3", "P3v3", "S1", "S2", "S3", "SHARED", "Y1", "EP1", "EP2", "EP3", "WS1", "WS2", "WS3"], var.sku_name), true)
    error_message = "The `sku_name` value must be valid. Possible values include B1, B2, B3, D1, F1, FREE, I1, I2, I3, I1v2, I2v2, I3v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, S1, S2, S3, SHARED, Y1, EP1, EP2, EP3, WS1, WS2, and WS3."
  }
}