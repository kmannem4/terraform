output "mssql_mi_output" {
  value = { for k, v in azurerm_mssql_managed_instance.mssql_mi :
    k => {
      id       = v.id
      fqdn     = v.fqdn
      dns_zone = v.dns_zone
      name     = v.name
    }
  }
  description = "The ID, FQDN and DNS zone of the Azure SQL Managed Instance."
}
output "mssql_mi_database_output" {
  value = { for k, v in azurerm_mssql_managed_database.mssql_mi_database :
    k => {
      id   = v.id
      name = v.name
    }
  }
  description = "The ID and name of the Azure SQL Managed Instance database."
}