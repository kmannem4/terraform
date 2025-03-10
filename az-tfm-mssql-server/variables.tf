# Resource Group Variables
variable "mssqlserver_name" {
  description = "The Name of the Resource Group"
  type        = string
}

variable "resource_group_name" {
  description = "The Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Resource Group should exist"
  type        = string
}

variable "administrator_login" {
  description = "Azure sql database login user name"
  type        = string
}

variable "administrator_login_password" {
  description = "Azure sql database login password"
  type        = string
}

variable "minimum_tls_version" {
  description = "certificate tls version"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
