module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "mssql_server" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_AZURE_113: "Ensure that SQL server disables public network access"
  #checkov:skip=CKV_AZURE_24: "Ensure that 'Auditing' Retention is 'greater than 90 days' for SQL servers"
  #checkov:skip=CKV2_AZURE_27: "Ensure Azure AD authentication is enabled for Azure SQL (MSSQL)"
  #checkov:skip=CKV_AZURE_23: "Ensure that 'Auditing' is set to 'On' for SQL servers"
  #checkov:skip=CKV2_AZURE_45: "Ensure Microsoft SQL server is configured with private endpoint"
  depends_on                   = [module.rg]
  source                       = "../"
  mssqlserver_name             = local.mssql_server_name
  resource_group_name          = local.resource_group_name
  location                     = var.location
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.minimum_tls_version
  tags                         = var.tags
}
