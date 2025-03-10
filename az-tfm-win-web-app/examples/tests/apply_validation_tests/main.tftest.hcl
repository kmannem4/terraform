provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "app_service_attribute_actual_vs_expected_test_apply" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.app_service_plan.service_plan_name == local.app_service_plan_name
    error_message = "app service plan name is not matching with given variable value"
  }
  assert {
    condition     = module.app_service_plan.service_plan_location == var.location
    error_message = "location is not matching with given variable value"
  }
  assert {
    condition     = module.app_service_plan.os_type == var.os_type
    error_message = "OS Type name is not matching with given variable value"
  }
  assert {
    condition     = module.app_service_plan.sku_name == var.sku_name
    error_message = "SKU name is not matching with given variable value"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_name } } == { for k, v in local.web_app_service_vars : k => { value = v.web_app_name } }
    error_message = "Windows web app service name is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_https_only } } == { for k, v in local.web_app_service_vars : k => { value = v.web_app_https_only } }
    error_message = "Windows web app service accepts https only is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_site_config_ftps_state } } == { for k, v in local.web_app_service_vars : k => { value = v.web_app_site_config.site_config_ftps_state } }
    error_message = "Windows web app service ftps state is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_site_config_always_on } } == { for k, v in local.web_app_service_vars : k => { value = v.web_app_site_config.site_config_always_on } }
    error_message = "Windows web app service site config always on is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_site_config_site_config_minimum_tls_version } } == { for k, v in local.web_app_service_vars : k => { value = v.web_app_site_config.site_config_minimum_tls_version } }
    error_message = "Windows web app service site config minimum tls version is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_kind } } == { for k, v in local.web_app_service_vars : k => { value = "app" } }
    error_message = "Windows web app service kind is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.virtual_network_swift_connection : k => { value = v.is_virtual_network_swift_connection_required } } == { for k, v in local.web_app_service_vars : k => { value = v.is_virtual_network_swift_connection_required } }
    error_message = "Windows web app virtual network swift connection variable is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_default_hostname } } == { for k, v in local.web_app_service_vars : k => { value = "${v.web_app_name}.azurewebsites.net" } }
    error_message = "Windows web app default hostname is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_location } } == { for k, v in local.web_app_service_vars : k => { value = var.location } }
    error_message = "Windows web app location is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_public_network_access_enabled } } == { for k, v in local.web_app_service_vars : k => { value = v.public_network_access_enabled } }
    error_message = "Windows web app public network access enabled is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.web_app_service_enabled } } == { for k, v in local.web_app_service_vars : k => { value = v.is_web_app_enabled } }
    error_message = "Windows web app is enabled not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.windows_web_app_service : k => { value = v.log } } == { for k, v in local.web_app_service_vars : k => { value = v.logs.0.application_logs.0.file_system_level } }
    error_message = "Windows web app log's file_system_level is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.key_vault_access_policy : k => { value = v.is_key_vault_access_policy_required } } == { for k, v in local.web_app_service_vars : k => { value = v.is_kv_access_policy_required } }
    error_message = "Windows web app KeyVault access policy enabled is not same as given in variable"
  }

  assert {
    condition     = { for k, v in module.web_app_service.key_vault_secret_permissions : k => { secret_permissions = v.secret_permissions } } == { for k, v in local.web_app_service_vars : k => { secret_permissions = tolist(v.secret_permissions) } }
    error_message = "Windows web app service secret permissions is not same as given in variable"
  }
  assert {
    condition     = { for k, v in module.web_app_service.key_vault_key_permissions : k => { key_permissions = v.key_permissions } } == { for k, v in local.web_app_service_vars : k => { key_permissions = tolist(v.key_permissions) } }
    error_message = "Windows web app service key permissions is not same as given in variable"
  }
}
