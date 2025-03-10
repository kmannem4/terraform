location = "westus2"

data_factory_config = {
  data_factory_name = "co-wus2-tftest-adf-t1313"
  public_network_enabled = true
  managed_virtual_network_enabled = true
  identity = "SystemAssigned"
  global_parameter = {}
  github_configuration = {}
  vsts_configuration = {
    account_name = "AMNEngineering"
    branch_name = "main"
    project_name = "AMNOne"
    repository_name = "AMIE2.DataFactory"
    root_folder = "/"
  }
}

tags = {
  charge-to = "101-71200-5000-9500"
  environment = "test"
  application = "Platform Services"
  product = "Platform Services"
  amnonecomponent = "shared"
  role = "infrastructure-tf-unit-test"
  managed-by = "cloud.engineers@amnhealthcare.com"
  owner = "cloud.engineers@amnhealthcare.com"
}
