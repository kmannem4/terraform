
resource "azurerm_signalr_service" "signalr" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  sku {
    capacity = var.sku.capacity
    name     = var.sku.name
  }

  dynamic "identity" {
    for_each = var.identity.identity_ids != [] ? [1] : []

    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }
  
  dynamic "cors" {
    for_each = length(var.allowed_origins) > 0 ? ["fake"] : []
    content {
      allowed_origins = var.allowed_origins
    }
  }

  connectivity_logs_enabled     = var.connectivity_logs_enabled
  messaging_logs_enabled        = var.messaging_logs_enabled
  # `live_trace_enabled` has been deprecated in favor of `live_trace` and will be removed in 4.0.
  // live_trace_enabled            = var.live_trace_enabled
  live_trace {
    enabled                   = var.live_trace_enabled
    messaging_logs_enabled    = var.messaging_logs_enabled
    connectivity_logs_enabled = var.connectivity_logs_enabled
    http_request_logs_enabled = var.http_request_logs_enabled
  }
  service_mode                  = var.service_mode
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

resource "azurerm_signalr_service_network_acl" "networkACLs" {
  signalr_service_id = azurerm_signalr_service.signalr.id
  default_action     = var.network_acl_default_action

  dynamic "public_network" {
    for_each = (var.network_acl_default_action == "Deny") ? toset([1]) : toset([])
    content {
      allowed_request_types = var.public_network_allowed_request_types
    }
  }
  dynamic "public_network" {
    for_each = (var.network_acl_default_action == "Allow") ? toset([1]) : toset([])
    content {
      denied_request_types = var.public_network_denied_request_types
    }
  }

  # TODO: Private endpoint configurations 
  // private_endpoint {
  //   id                    = azurerm_private_endpoint.example.id
  //   allowed_request_types = ["ServerConnection"]
  // }
}