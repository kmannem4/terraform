resource "azurerm_container_app_environment" "main" {
  for_each            = var.container_app_environment_vars
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  mutual_tls_enabled                          = each.value.mutual_tls_enabled
  internal_load_balancer_enabled              = each.value.internal_load_balancer_enabled
  zone_redundancy_enabled                     = each.value.zone_redundancy_enabled
  dapr_application_insights_connection_string = each.value.dapr_application_insights_connection_string

  log_analytics_workspace_id         = var.log_analytics_workspace_id
  infrastructure_resource_group_name = var.infrastructure_resource_group_name
  infrastructure_subnet_id           = var.infrastructure_subnet_id

  dynamic "workload_profile" {
    for_each = each.value.workload_profile != null ? each.value.workload_profile : []
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }
}
