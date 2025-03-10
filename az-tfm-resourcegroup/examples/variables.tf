# Resource Group Variables
variable "resource_group_name" {
  description = "The Name of the Resource Group"
  type        = string
  default     = "rg-demo-westeurope-01"
}

variable "location" {
  description = "The Azure Region where the Resource Group should exist"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "A mapping of tags which should be assigned to all resources"
  type        = map(any)
  default     = {}
}