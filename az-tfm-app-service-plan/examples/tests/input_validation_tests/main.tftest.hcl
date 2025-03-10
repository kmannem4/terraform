provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run app_service_plan_attribute_actual_vs_expected_test_apply {
    command = apply
    // TODO: Add more unit tests
    assert {
        condition = module.app_service_plan.service_plan_name == var.app_service_plan_name
        error_message = "app service plan name is not matching with given variable value"
    }

    assert {
        condition = module.app_service_plan.os_type == var.os_type
        error_message = "OS type is not matching with given variable value"
    }

    assert {
        condition = module.app_service_plan.sku_name == var.sku_name
        error_message = "SKU name is not matching with given variable value"
    }
}
