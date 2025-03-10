variable "resource_group_name" {
  description = "The name of the resource group in which to create the Function App."
  default     = null
  type        = string
}
variable "location" {
  type = string
}
variable "tags" {
  validation {
    condition     = length(keys(var.tags)) <= 15
    error_message = "The number of tags must not exceed 15."
  }
}
variable "function_app_name_vars" {
  description = "The name of the Function App."
  type = map(object({
    function_app_name                            = string       #The name of the Function App.
    app_service_plan_name                        = string       #The name of the App Service Plan.
    storage_account_name                         = string       #The name of the Storage Account.
    virtual_network_name                         = string       #The name of the Virtual Network for Vnet Integration.
    vnet_subnet                                  = string       #The name of the Subnet for Vnet Integration.
    vnet_resource_group_name                     = string       #The name of the Resource Group for Vnet Integration.
    storage_resource_group_name                  = string       #The name of the Resource Group for Storage Account.
    key_vault_resource_group_name                = string       #The name of the Resource Group for Key Vault.
    key_vault                                    = string       #The name of the Key Vault for Key Vault Secret Access.
    https_only                                   = bool         #Configures a web site to accept only https requests. Default value is false.
    app_settings                                 = map(string)  #A key-value pair of App Settings.
    secret_permissions                           = list(string) #The permissions the Function App identity has on the Key Vault Secret.
    ftps_state                                   = string       #State of FTP / FTPS service for this function app. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
    minimum_tls_version                          = string       #The minimum version of TLS required for this function app. Possible values include: 1.0, 1.1, 1.2. Default value is 1.2.
    public_network_access_enabled                = bool
    is_kv_access_policy_required                 = bool
    is_network_config_required                   = bool
    is_virtual_network_swift_connection_required = bool
    is_log_analytics_workspace_id_required       = bool
    log_analytics_workspace_id                   = string
    ip_restrictions = list(object({
      ipAddress   = string
      action      = string
      service_tag = string
      priority    = number
      name        = string
      description = string
    }))
    function_app_identity = object({
      function_app_identity_type = string
    })
  }))

}

