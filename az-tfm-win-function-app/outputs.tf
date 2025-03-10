output "windows_function_app" {
  value = { for key, value in azurerm_windows_function_app.function_app :
    key => {
      function_app_name                                        = value.name
      function_app_location                                    = value.location
      function_app_hostname                                    = value.default_hostname
      function_app_kind                                        = value.kind
      function_app_id                                          = value.id
      function_app_https_enabled                               = value.https_only
      function_app_identity                                    = value.identity
      function_app_minimum_tls_version                         = value.site_config.0.minimum_tls_version
      function_app_public_network_access_enabled               = value.public_network_access_enabled
      function_app_site_config_always_on                       = value.site_config.0.always_on
      function_app_site_config_site_config_minimum_tls_version = value.site_config.0.minimum_tls_version
      function_app_site_config_ftps_state                      = value.site_config.0.ftps_state
      function_app_site_config_http2_enabled                   = value.site_config.0.http2_enabled
      function_app_ip_restrictions                             = value.site_config.0.ip_restriction
    }
  }
}


output "function_app_virtual_network_swift_connection" {
  value = {
    for name, config in var.function_app_name_vars : name => {
      is_virtual_network_swift_connection_required = config.is_virtual_network_swift_connection_required
    }
  }
}

output "function_app_key_vault_access_policy" {
  value = {
    for name, config in var.function_app_name_vars : name => {
      is_kv_access_policy_required = config.is_kv_access_policy_required
    }
  }
}