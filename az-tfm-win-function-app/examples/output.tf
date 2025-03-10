output "windows_function_app" {
  description = "value"
  value       = module.function_app.windows_function_app
}


# output "ip" {
#   value = module.function_app.windows_function_app == { for key, value in var.function_app_name_vars :   key => { function_app_site_config_ip_rest   = { for ip_restriction in value.ip_restrictions : ip_restriction.name => { action  = ip_restriction.action } } } } # { for ip_restriction in value.ip_restrictions : ip_restriction.name => { action  = ip_restriction.action } } 
# }