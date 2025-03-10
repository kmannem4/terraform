provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "apply_validation_unit_test" {
  command = apply
  #1
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_hostname } } == { for k, v in local.function_app_name_vars : k => { value = "${v.function_app_name}.azurewebsites.net" } }
    error_message = "Windows Function App hostname is not matching with given variable value"
  }
  #2  
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_location } } == { for k, v in local.function_app_name_vars : k => { value = var.location } }
    error_message = "Windows Function app location is not same as given in variable"
  }
  #3
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_kind } } == { for key, value in local.function_app_name_vars : key => { value = "functionapp" } }
    error_message = "Windows Function App Kind not matching with functionapp"
  }

  #5
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_https_enabled } } == { for k, v in local.function_app_name_vars : k => { value = v.https_only } }
    error_message = "Windows Function app service https enabled is not same as given in variable"
  }
  #6
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_name } } == { for k, v in local.function_app_name_vars : k => { value = v.function_app_name } }
    error_message = "Windows function app service name is not same as given in variable"
  }
  #7
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_minimum_tls_version } } == { for k, v in local.function_app_name_vars : k => { value = v.minimum_tls_version } }
    error_message = "Windows function app Minimum TLS version is not same as given in variable"
  }
  #8
  assert {
    condition     = { for k, v in module.function_app.windows_function_app : k => { value = v.function_app_public_network_access_enabled } } == { for k, v in local.function_app_name_vars : k => { value = v.public_network_access_enabled } }
    error_message = "Windows function app public network access enabled is not same as given in variable"
  }
  #9
  assert {
    condition     = { for k, v in module.function_app.function_app_virtual_network_swift_connection : k => { value = v.is_virtual_network_swift_connection_required } } == { for k, v in local.function_app_name_vars : k => { value = v.is_virtual_network_swift_connection_required } }
    error_message = "Windows function app virtual network swift connection value is not same as given in variable"
  }
  #10
  assert {
    condition     = { for k, v in module.function_app.function_app_key_vault_access_policy : k => { value = v.is_kv_access_policy_required } } == { for k, v in local.function_app_name_vars : k => { value = v.is_kv_access_policy_required } }
    error_message = "Windows function app Key vault access policies value is not same as given in variable"
  }
}

