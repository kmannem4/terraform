variable "location" {
  description = "Azure location."
  type        = string
}

variable "container_registry_name" {
  description = "container registry name"
  type        = string
}

variable "admin_enabled" {
  description = "admin enabled"
  type        = bool
}
variable "sku_name" {
  description = "The SKU for the container registry."
  type        = string
}

variable "georeplications_location" {
  description = "The georeplications location for the container registry."
  type        = string
}

variable "georeplications_zone_redundancy_enabled" {
  description = "The georeplications zone redundancy enabled for the container registry."
  type        = bool
}

variable "zone_redundancy_enabled" {
  description = "The zone redundancy enabled for the container registry."
  type        = bool
}
variable "public_network_access_enabled" {
  description = "The public network access enabled for the container registry."
  type        = bool
}

variable "default_action" {
  description = "The default action for the container registry."
  type        = string
}

variable "ip_range" {
  description = "The ip range for the container registry."
  type        = string
}

variable "action" {
  description = "The action for the container registry."
  type        = string
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}
