variable "location" {
  description = "Azure location."
  type        = string
}

variable "create_resource_group" {
  description = "Resource group to create"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "user_assigned_identity_name" {
  description = "Name of the User Assigned Identity"
  type        = string
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}