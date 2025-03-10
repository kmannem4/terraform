# Purpose: Define the input variables for the module.
variable "location" {
  description = "Azure location."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}

variable "linux_web_app_service_vars" {
  type = map(object({
    linux_web_app_name    = string
    app_service_plan_name = string
    web_app_settings      = map(string)
    web_app_site_config = object({
      site_config_always_on           = bool
      site_config_ftps_state          = string
      site_config_minimum_tls_version = string
      site_config_http2_enabled       = bool
      site_config_use_32_bit_worker   = bool
      site_config_cors = list(object({
        site_config_cors_allowed_origins     = list(string)
        site_config_cors_support_credentials = string
      }))
      application_stack = optional(object({
        dotnet_version      = optional(string)
        java_version        = optional(string)
        node_version        = optional(string)
        php_version         = optional(string)
        python_version      = optional(string)
        java_server         = optional(string)
        java_server_version = optional(string)
        ruby_version        = optional(string)
        go_version          = optional(string)
        docker_image_name = optional(string)
        docker_registry_url = optional(string)
        docker_registry_username = optional(string)
        docker_registry_password = optional(string)
      }))
      web_app_ip_restriction = optional(map(object({
        web_app_ip_restriction_name                      = string
        web_app_ip_restriction_action                    = string
        web_app_ip_restriction_priority                  = string
        web_app_ip_restriction_ip_address                = optional(string)
        web_app_ip_restriction_service_tag               = optional(string)
        web_app_ip_restriction_virtual_network_subnet_id = optional(string)
        web_app_ip_restriction_headers = optional(list(object({
          headers_x_azure_fdid      = optional(list(string))
          headers_x_fd_health_probe = optional(list(string))
          headers_x_forwarded_for   = optional(list(string))
          headers_x_forwarded_host  = optional(list(string))
        })))
      })))
    })

    connection_strings = map(object({
      name  = string # Required: The name of the connection string
      type  = string # Required: The type of the database
      value = string # Required: The actual connection string value
    }))
    web_app_https_only                                 = bool
    is_web_app_enabled                                 = bool
    public_network_access_enabled                      = bool
    is_network_config_required                         = bool
    network_config_virtual_network_name                = string
    network_config_subnet_name                         = string
    network_config_virtual_network_resource_group_name = string
    is_virtual_network_swift_connection_required       = bool
    is_appinsights_instrumentation_key_required        = bool
    is_log_analytics_workspace_id_required             = bool
    log_analytics_workspace_id                         = string
    web_app_application_insights_name                  = string
    web_app_application_insights_resource_group_name   = string
    logs = list(object({
      application_logs = list(object({
        file_system_level = string
      }))
    }))
    key_permissions              = list(string)
    secret_permissions           = list(string)
    is_kv_access_policy_required = bool
    kv_name                      = string
    kv_resource_group_name       = string
    web_app_identity = object({
      web_app_identity_type = string
    })
  }))
  description = "Map of variables for Linux Web App"
  default     = {}
}

