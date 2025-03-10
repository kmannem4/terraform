output "db_server_name" {
  description = "Database instance hostname."
  value       = azurerm_postgresql_flexible_server.postgres.name
}

output "postgresql_flexible_server_identity_principal_id" {
  value = azurerm_postgresql_flexible_server_identity.postgres.principal_id
}

