provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run container_registry_attribute_actual_vs_expected_test_apply {
    command = apply
    // TODO: Add more unit tests
    assert {
        condition = module.container_registry.container_registry_name == var.container_registry_name
        error_message = "container name is not matching with given variable value"
    }
    assert {
        condition = module.container_registry.sku_name == var.sku_name
        error_message = "SKU name is not matching with given variable value"
    }
    assert {
        condition = module.container_registry.location == var.location
        error_message = "location is not matching with given variable value"
    }
    assert {
        condition = module.container_registry.admin_enabled == var.admin_enabled
        error_message = "admin enabled is not matching with given variable value"
    }
    assert {
        condition = module.container_registry.public_network_access_enabled == var.public_network_access_enabled
        error_message = "public network access enabled is not matching with given variable value"
    }
    assert {
        condition = module.container_registry.zone_redundancy_enabled == var.zone_redundancy_enabled
        error_message = "zone redundancy enabled is not matching with given variable value"
    }
}
