variable "name" {
  description = "Specifies the name of this Load Test. Changing this forces a new Load Test to be created."
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group within which this Load Test should exist. Changing this forces a new Load Test to be created."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Load Test should exist. Changing this forces a new Load Test to be created."
  type        = string
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

variable "customer_managed_key_url" {
  description = "The URI specifying the Key vault and key to be used to encrypt data in this resource. The URI should include the key version. Changing this forces a new Load Test to be created."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}