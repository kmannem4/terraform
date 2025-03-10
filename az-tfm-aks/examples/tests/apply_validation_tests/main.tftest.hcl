provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run "actual_vs_expected_test_apply" {
  command = apply

  assert {
    condition     = module.aks.aks_id != null 
    error_message = "Error: The ID of the Azure Kubernetes Service must not be null."
  }

  assert {
    condition     = endswith(module.aks.cluster_fqdn, ".hcp.westus2.azmk8s.io")
    error_message = "Error: The FQDN of the Azure Kubernetes Managed Cluster must end with '.hcp.westus2.azmk8s.io'."
  }

  assert {
    condition     = endswith(module.aks.cluster_portal_fqdn, ".portal.hcp.westus2.azmk8s.io") 
    error_message = "Error: The identity block of the Azure Kubernetes Service must not be null."
  }

  assert {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(\\/\\d{1,2})?$", module.aks.network_profile[0].pod_cidr))
    error_message = "IP address format is invalid"
  }
  assert {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(\\/\\d{1,2})?$", module.aks.network_profile[0].service_cidr))
    error_message = "IP address format is invalid"
  }
}

