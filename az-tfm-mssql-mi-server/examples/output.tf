output "mssql_mi" {
  value       = module.mssql_mi_server.mssql_mi_output
  description = "Azure SQL Managed Instance."
}
output "mssql_mi_database_output" {
  value       = module.mssql_mi_server.mssql_mi_database_output
  description = "The ID and name of the Azure SQL Managed Instance database."
}
