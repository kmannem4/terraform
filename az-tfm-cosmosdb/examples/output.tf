output "cosmons_db_account_id" {
  description = "The ID of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_id
}

output "cosmons_db_account_endpoint" {
  description = "The endpoint of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_endpoint
}

output "cosmons_db_account_read_endpoints" {
  description = "The read_endpoints of the cosmons_db_account."
  # value       = module.cosmons_db_account.cosmons_db_account_read_endpoints
  # format      = "%s" 
  value = [for k in module.cosmons_db_account.cosmons_db_account_read_endpoints : {
    read_endpoint = k }
  ]
}

output "cosmons_db_account_write_endpoints" {
  description = "The write_endpoints of the cosmons_db_account."
  value = [for k in module.cosmons_db_account.cosmons_db_account_write_endpoints : {
    write_endpoint = k }
  ]
}

output "cosmons_db_account_primary_key" {
  description = "The primary_key of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_primary_key
  sensitive   = true
}

output "cosmons_db_account_secondary_key" {
  description = "The secondary_key of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_secondary_key
  sensitive   = true
}

output "cosmons_db_account_primary_readonly_key" {
  description = "The primary_readonly_key of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_primary_readonly_key
  sensitive   = true
}

output "cosmons_db_account_secondary_readonly_key" {
  description = "The secondary_readonly_key of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_secondary_readonly_key
  sensitive   = true
}

output "cosmons_db_account_primary_sql_connection_string" {
  description = "The primary_sql_connection_string of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_primary_sql_connection_string
  sensitive   = true
}

output "cosmons_db_account_secondary_sql_connection_string" {
  description = "The secondary_sql_connection_string of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_secondary_sql_connection_string
  sensitive   = true
}

output "cosmons_db_account_primary_readonly_sql_connection_string" {
  description = "The primary_readonly_sql_connection_string of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_primary_readonly_sql_connection_string
  sensitive   = true
}

output "cosmons_db_account_secondary_readonly_sql_connection_string" {
  description = "The secondary_readonly_sql_connection_string of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_secondary_readonly_sql_connection_string
  sensitive   = true
}

#CosmosDB SQL Database Output
output "cosmosdb_sql_database_output" {
  description = "The ID of the CosmosDB SQL Database output values"
  value       = module.cosmons_db_account.cosmosdb_sql_database_output
}

#CosmosDB Name Output
output "cosmos_db_account_name" {
  description = "The name of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmos_db_account_name
}

#CosmosDB kind Output
output "cosmons_db_account_kind" {
  description = "The kind of the cosmons_db_account."
  value       = module.cosmons_db_account.cosmons_db_account_kind
}

#CosmosDB SQL Container Output
output "cosmosdb_sql_container_output" {
  description = "The ID of the CosmosDB SQL Container output values"
  value       = module.cosmons_db_account.cosmosdb_sql_container_output
}
