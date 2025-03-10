// variable "resource_group_name" {
//   description = "Resource group name"
//   type        = string
// }

// variable "servicebus_name" {
//   description = "Name of the Servicebus"
//   type        = string
// }

variable "servicebus_sku_name" {
  description = "Sku of the Servicebus"
  type        = string
}


// variable "mgid" {
//   description = "mgid"
//   type        = string
// }

variable "role" {
  description = "role"
  type        = string
}

variable "location" {
  description = "Azure location."
  default     = "westus2"
  type        = string
}


variable "servicebus_location" {
  description = "Azure location."
  default     = "westus2"
  type        = string
}


variable "tags" {
  description = "Tags to add"
  type        = map(string)
}