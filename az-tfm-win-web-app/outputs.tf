# Purpose: Define the output variables for the Terraform configuration.
output "windows_web_app_service" {
  description = "Windows Web App Service"
  value = {
    for k, v in azurerm_windows_web_app.web_app_service :
    k => {
      web_app_service_id                                          = v.id
      web_app_service_kind                                        = v.kind
      web_app_service_hosting_environment_id                      = v.hosting_environment_id
      web_app_service_outbound_ip_addresses                       = v.outbound_ip_addresses
      web_app_service_possible_outbound_ip_addresses              = v.possible_outbound_ip_addresses
      web_app_service_name                                        = v.name
      web_app_service_default_hostname                            = v.default_hostname
      web_app_service_enabled                                     = v.enabled
      web_app_service_identity                                    = v.identity
      web_app_service_https_only                                  = v.https_only
      web_app_service_public_network_access_enabled               = v.public_network_access_enabled
      web_app_service_site_config_always_on                       = v.site_config.0.always_on
      web_app_service_site_config_site_config_minimum_tls_version = v.site_config.0.minimum_tls_version
      web_app_service_site_config_ftps_state                      = v.site_config.0.ftps_state
      web_app_service_site_config_http2_enabled                   = v.site_config.0.http2_enabled
      web_app_service_site_config_linux_fx_version                = v.site_config.0.linux_fx_version
      web_app_service_site_config_local_mysql_enabled             = v.site_config.0.local_mysql_enabled
      web_app_service_site_config_managed_pipeline_mode           = v.site_config.0.managed_pipeline_mode
      web_app_service_site_config_remote_debugging_enabled        = v.site_config.0.remote_debugging_enabled
      web_app_service_site_config_remote_debugging_version        = v.site_config.0.remote_debugging_version
      web_app_service_site_config_scm_type                        = v.site_config.0.scm_type
      web_app_service_default_hostname                            = v.default_hostname
      web_app_service_location                                    = v.location
      log                                                         = v.logs.0.application_logs.0.file_system_level
    }
  }
}

output "virtual_network_swift_connection" {
  description = "Virtual Network Swift Connection"
  value = {
    for k, v in azurerm_windows_web_app.web_app_service :
    k => {
      is_virtual_network_swift_connection_required = contains(keys(azurerm_app_service_virtual_network_swift_connection.virtual_network_swift_connection), k) ? true : false
    }
  }
}


output "key_vault_access_policy" {
  description = "Key Vault Access Policy"
  value = {
    for k, v in azurerm_windows_web_app.web_app_service :
    k => {
      is_key_vault_access_policy_required = try(contains(keys(azurerm_key_vault_access_policy.key_vault_access_policy), k), false)
    }
  }
}

output "key_vault_secret_permissions" {
  description = "Key Vault Secret Permissions"
  value = {
    for k, v in azurerm_windows_web_app.web_app_service :
    k => {
      secret_permissions = try(azurerm_key_vault_access_policy.key_vault_access_policy[k].secret_permissions, [])
    }
  }
}

output "key_vault_key_permissions" {
  description = "Key Vault Key Permissions"
  value = {
    for k, v in azurerm_windows_web_app.web_app_service :
    k => {
      key_permissions = try(azurerm_key_vault_access_policy.key_vault_access_policy[k].key_permissions, [])
    }
  }
}