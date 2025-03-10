output "mssql_server_id" {
  value       = azurerm_mssql_server.example.id
  description = "The ID of the SQL server"
}
 
output "mssql_server_name" {
  value       = azurerm_mssql_server.example.name
  description = "The name of the SQL server"
}
 
output "mssql_server_fqdn" {
  value       = azurerm_mssql_server.example.fully_qualified_domain_name
  description = "The fully qualified domain name of the SQL server"
}
 
output "mssql_administrator_login" {
  value       = azurerm_mssql_server.example.administrator_login
  description = "The administrator login for the SQL server"
}