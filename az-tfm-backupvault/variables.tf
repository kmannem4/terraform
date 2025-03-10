variable "name" {
  description = "Specifies the name of this Load Test. Changing this forces a new Load Test to be created."
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group within which this Load Test should exist. Changing this forces a new Load Test to be created."
  type        = string
}

variable "location" {
  description = "The Azure Region where the backup vault should exist. Changing this forces a new backup vault to be created."
  type        = string
  default     = ""
}

variable "description" {
  description = "Description of the resource. Changing this forces a new Load Test to be created."
  type        = string
  default     = ""
}
variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}

variable "datastore_type" {
  description = "Specifies the type of the data store."
  type        = string
  default     = ""
}

variable "redundancy" {
  description = "Specifies the backup storage redundancy."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}