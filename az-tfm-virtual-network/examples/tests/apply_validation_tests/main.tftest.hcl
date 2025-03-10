provider "azurerm" {
  features {}
    subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run vnet_attribute_actual_vs_expected_test_apply {
  command = apply
  // TODO: Add more unit tests
  assert {
    condition     = module.virtual_network.virtual_network_name == var.vnetwork_name
    error_message = "Virtual network name is not matching with the given variable value"
  }
  assert {
    condition     = module.virtual_network.resource_group_location == var.location
    error_message = "Virtual network location is not matching with the given variable value"
  }
  assert {
    condition     = tolist(module.virtual_network.virtual_network_address_space )== tolist(var.vnet_address_space)
    error_message = "Virtual network address_space is not matching with the given variable value"
  }

  assert {
    condition     = module.virtual_network.subnet_address_prefixes == flatten(concat([for s in var.subnets : s.subnet_address_prefix], [var.gateway_subnet_address_prefix != null ? var.gateway_subnet_address_prefix : null], [var.firewall_subnet_address_prefix != null ? var.firewall_subnet_address_prefix : null]))
    error_message = "Virtual network subnet_address_prefixes is not matching with the given variable value"
  }
  assert {
    condition     = module.virtual_network.edge_zone == (var.edge_zone == "" ? null : var.edge_zone)
    error_message = "Virtual network edge_zone is not matching with the given variable value"
  }
  assert {
    condition     = module.virtual_network.flow_timeout_in_minutes == (var.flow_timeout_in_minutes == 0 ? null : var.flow_timeout_in_minutes)
    error_message = "Virtual network flow_timeout_in_minutes is not matching with the given variable value"
  }
  assert {
    condition     = module.virtual_network.ddos_plan_name == (var.create_ddos_plan ? var.ddos_plan_name : "")
    error_message = "Virtual network ddos_plan_name is not matching with the given variable value"
  }
  assert {
    condition     = module.virtual_network.dns_servers == var.dns_servers
    error_message = "Virtual network dns_servers is not matching with the given variable value"
  }
  assert {
    condition     = module.virtual_network.network_security_group_names == { for k, v in var.subnets : k => { value = "nsg_${k}_in" } }
    error_message = "Virtual network nsg names is not matching with the given variable value"
  }
}  