output "cosmons_db_account_id" {
  description = "The ID of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.id
}

output "cosmos_db_account_name" {
  description = "The name of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.name
}

output "cosmons_db_account_kind" {
  description = "The kind of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.kind
}

output "cosmons_db_account_endpoint" {
  description = "The endpoint of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.endpoint
}

output "cosmons_db_account_read_endpoints" {
  description = "The read_endpoints of the cosmons_db_account."
  # value       = azurerm_cosmosdb_account.cosmons_db_account.read_endpoints
  # format      = "%s" 
  value = [for k in azurerm_cosmosdb_account.cosmons_db_account.read_endpoints : {
    read_endpoint = k }
  ]
}

output "cosmons_db_account_write_endpoints" {
  description = "The write_endpoints of the cosmons_db_account."
  value = [for k in azurerm_cosmosdb_account.cosmons_db_account.write_endpoints : {
    write_endpoint = k }
  ]
}

output "cosmons_db_account_primary_key" {
  description = "The primary_key of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.primary_key
  sensitive   = true
}

output "cosmons_db_account_secondary_key" {
  description = "The secondary_key of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.secondary_key
  sensitive   = true
}

output "cosmons_db_account_primary_readonly_key" {
  description = "The primary_readonly_key of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.primary_readonly_key
  sensitive   = true
}

output "cosmons_db_account_secondary_readonly_key" {
  description = "The secondary_readonly_key of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.secondary_readonly_key
  sensitive   = true
}

output "cosmons_db_account_primary_sql_connection_string" {
  description = "The primary_sql_connection_string of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.primary_sql_connection_string
  sensitive   = true
}

output "cosmons_db_account_secondary_sql_connection_string" {
  description = "The secondary_sql_connection_string of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.secondary_sql_connection_string
  sensitive   = true
}

output "cosmons_db_account_primary_readonly_sql_connection_string" {
  description = "The primary_readonly_sql_connection_string of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.primary_readonly_sql_connection_string
  sensitive   = true
}

output "cosmons_db_account_secondary_readonly_sql_connection_string" {
  description = "The secondary_readonly_sql_connection_string of the cosmons_db_account."
  value       = azurerm_cosmosdb_account.cosmons_db_account.secondary_readonly_sql_connection_string
  sensitive   = true
}

#CosmosDB SQL Database Output
output "cosmosdb_sql_database_output" {
  description = "The ID of the CosmosDB SQL Database output values"
  value = { for k, v in azurerm_cosmosdb_sql_database.cosmosdb_sql_database : k => {
    id = v.id }
  }
}

#CosmosDB SQL Container Output
output "cosmosdb_sql_container_output" {
  description = "The ID of the CosmosDB SQL Container output values"
  value = { for k, v in azurerm_cosmosdb_sql_container.cosmosdb_sql_container : k => {
    id = v.id }
  }
}
