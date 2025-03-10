provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "actual_vs_expected_test_apply" {
  command = apply

  assert {
    condition     = module.signalr.id != ""
    error_message = "Error: The ID of the SignalR service must not be null."
  }

  assert {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", module.signalr.ip_address))
    error_message = "IP address format is invalid"
  }

  assert {
    condition     = issensitive(module.signalr.primary_access_key)
    error_message = "Secondary connection string output is not sensitive"
  }

  assert {
    condition     = issensitive(module.signalr.secondary_access_key)
    error_message = "Secondary connection string format is not sensitive"
  }

  assert {
    condition     = module.signalr.public_port >= 1 && module.signalr.public_port <= 65535
    error_message = "Public port is out of valid range (1-65535)"
  }

  assert {
    condition     = module.signalr.server_port >= 1 && module.signalr.server_port <= 65535
    error_message = "Server port is out of valid range (1-65535)"
  }

  assert {
    condition     = endswith(module.signalr.hostname, ".service.signalr.net")
    error_message = "Hostname is not valid"
  }
}
