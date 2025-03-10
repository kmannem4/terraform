data "azurerm_client_config" "current" {}

resource "azurerm_data_factory" "data_factory" {
  #checkov:skip=CKV2_AZURE_103: skip
  #checkov:skip=CKV2_AZURE_15: skip
  resource_group_name             = var.resource_group_name
  name                            = var.data_factory_config.data_factory_name
  location                        = var.location
  public_network_enabled          = var.data_factory_config.public_network_enabled
  managed_virtual_network_enabled = var.data_factory_config.managed_virtual_network_enabled

  dynamic "global_parameter" {
    for_each = var.data_factory_config.global_parameter.name != null ? [1] : []
    content {
      name  = var.data_factory_config.global_parameter.name
      type  = var.data_factory_config.global_parameter.type
      value = var.data_factory_config.global_parameter.value
    }
  }

  dynamic "github_configuration" {
    for_each = var.data_factory_config.github_configuration.account_name != null ? [1] : []
    content {
      account_name       = var.data_factory_config.github_configuration.account_name
      branch_name        = var.data_factory_config.github_configuration.branch_name
      git_url            = var.data_factory_config.github_configuration.git_url
      repository_name    = var.data_factory_config.github_configuration.repository_name
      root_folder        = var.data_factory_config.github_configuration.root_folder
      publishing_enabled = var.data_factory_config.github_configuration.publishing_enabled
    }
  }

  dynamic "vsts_configuration" {
    for_each = var.data_factory_config.vsts_configuration.account_name != null ? [1] : []
    content {
      account_name    = var.data_factory_config.vsts_configuration.account_name
      branch_name     = var.data_factory_config.vsts_configuration.branch_name
      project_name    = var.data_factory_config.vsts_configuration.project_name
      repository_name = var.data_factory_config.vsts_configuration.repository_name
      root_folder     = var.data_factory_config.vsts_configuration.root_folder
      tenant_id       = data.azurerm_client_config.current.tenant_id
    }
  }

  dynamic "identity" {
    for_each = var.data_factory_config.identity != null ? [1] : []
    content {
      type = var.data_factory_config.identity
    }
  }

  tags = var.tags
}
