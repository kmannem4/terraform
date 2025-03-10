# SEARCH SERVICE VARIABLES
variable "search_service_name" {
  type = string
}

variable "location" {
  type = string
}

variable "search_service_sku" {
  type    = string
  default = "standard"
}

variable "search_service_replica_count" {
  type    = string
  default = "1"
}

variable "search_service_partition_count" {
  type    = string
  default = "1"
}

variable "search_service_authentication_failure_mode" {
  type    = string
  default = null
}

variable "search_service_customer_managed_key_enforcement_enabled" {
  type    = bool
  default = false

}

variable "search_service_local_authentication_enabled" {
  type    = bool
  default = true
}

variable "search_service_hosting_mode" {
  type    = string
  default = "default"
}

variable "search_service_public_network_access_enabled" {
  type    = bool
  default = true
}

variable "search_service_allowed_ips" {
  type    = list(string)
  default = []
}

variable "search_service_identity" {
  type    = string
  default = "SystemAssigned"
}

variable "tags" {
  type = map(string)
  default = {
    application = "Infrastructure"
    product     = "Infrastructure"
    charge-to   = "101-71200-5000-9500"
    environment = "dev"
    managed-by  = ""
  }
}
