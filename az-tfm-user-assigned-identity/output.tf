output "mi_id" {
  value = azurerm_user_assigned_identity.mi.id
}

output "mi_principal_id" {
  value = azurerm_user_assigned_identity.mi.principal_id
}

output "mi_client_id" {
  value = azurerm_user_assigned_identity.mi.client_id
}

output "mi_tenant_id" {
  value = azurerm_user_assigned_identity.mi.tenant_id
}

output "mi_tenant_name" {
  value = azurerm_user_assigned_identity.mi.name
}

output "mi_tenant_location" {
  value = azurerm_user_assigned_identity.mi.location
}

output "mi_tenant_resource_group_name" {
  value = azurerm_user_assigned_identity.mi.resource_group_name
}