module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source                  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name     = local.resource_group_name
  location                = var.location
  tags                    = var.tags
}

module "signalr" {
  #checkov:skip=CKV_TF_1: skip
  #checkov:skip=CKV_TF_2: skip
  depends_on = [module.rg]
  source  = "../"

  name                = local.signalr_name
  location            = var.location
  resource_group_name = local.resource_group_name

  sku                 = var.sku

  connectivity_logs_enabled            = var.connectivity_logs_enabled
  messaging_logs_enabled               = var.messaging_logs_enabled
  live_trace_enabled                   = var.live_trace_enabled
  service_mode                         = var.service_mode
  public_network_access_enabled        = var.public_network_access_enabled
  public_network_allowed_request_types = var.public_network_allowed_request_types
  tags                                 = var.tags
}

check "signalr_health_check" {
  data "http" "signalr_health" {
     url = "https://${module.signalr.hostname}/api/v1/health"
  }
 
  assert {
     condition     = data.http.signalr_health.status_code == 200 || data.http.signalr_health.status_code == 473
     error_message = "SignalR returned an unhealthy status code"
  }
}