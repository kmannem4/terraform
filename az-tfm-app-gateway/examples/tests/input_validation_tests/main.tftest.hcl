provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "plan_tags_validation_unit_test" {
  command = plan
  // TODO: Add more unit tests
  assert {
    condition     = length(var.tags) > 0
    error_message = "Please Provide tags, it should be not empty!!"
  }
}

run "backend_address_pool_name_attribute_actual_vs_expected_test_destroy" {
  command = plan
  assert {
    condition = module.application-gateway.backend_address_pool_name[0] == var.backend_address_pools[0].name
    error_message = "backend address pool name is not matching with given variable value"
  }
}

run "backend_http_settings_name_attribute_actual_vs_expected_test_destroy" {
  command = plan
  assert {
    condition = module.application-gateway.backend_http_settings_name[0] == var.backend_http_settings[0].name
    error_message = "backend http settings name is not matching with given variable value"
  }
}

run "http_listener_name_attribute_actual_vs_expected_test_destroy" {
  command = plan
  assert {
    condition = module.application-gateway.http_listener_name[0] == var.http_listeners[0].name
    error_message = "http listener name is not matching with given variable value"
  }
}

run "app_gateway_attribute_actual_vs_expected_test_apply" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.application-gateway.app_gateway_name == local.app_gateway_name
    error_message = "app service plan name is not matching with given variable value"
  }
}

run "frontend_ip_configuration_name_attribute_actual_vs_expected_test_destroy" {
  command = apply

  assert {
    condition = module.application-gateway.frontend_ip_configuration_name[0] == local.frontend_ip_configuration_name
    error_message = "frontend ip configuration name is not matching with given variable value"
  }
}

run "gateway_ip_configuration_name_attribute_actual_vs_expected_test_destroy" {
  command = apply
  assert {
    condition = module.application-gateway.gateway_ip_configuration_name[0] == local.gateway_ip_configuration_name
    error_message = "gateway ip configuration name is not matching with given variable value"
  }
}