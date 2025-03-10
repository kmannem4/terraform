provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "redis_actual_attributes_vs_expected_test_apply_validation_tests" {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.redis.redis_name["test-redis"] == local.redis_name
    error_message = "Redis name is not matching with given variable value"
  }
}
