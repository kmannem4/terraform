output "mi_id" {
  description = "ID of the User Assigned Identity"
  value       = module.user_assigned_identity.mi_id
}

output "mi_principal_id" {
  description = "ID of the app associated with the Identity"
  value       = module.user_assigned_identity.mi_principal_id
}

output "mi_client_id" {
  description = "ID of the Service Principal object associated with the created Identity"
  value       = module.user_assigned_identity.mi_client_id
}

output "mi_tenant_id" {
  description = "Tenant ID of the User Assigned Identity"
  value       = module.user_assigned_identity.mi_tenant_id
}

output "mi_tenant_name" {
  description = "Name of the User Assigned Identity"
  value       = module.user_assigned_identity.mi_tenant_name
}

output "mi_tenant_location" {
  description = "Location of the User Assigned Identity"
  value       = module.user_assigned_identity.mi_tenant_location
}

output "mi_tenant_resource_group_name" {
  description = "Resource Group of the User Assigned Identity"
  value       = module.user_assigned_identity.mi_tenant_resource_group_name
}
