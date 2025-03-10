variable "location" {
  description = "Azure location."
  type        = string
}

variable "tags" {
  description = "Tags to add"
  type        = map(string)
  default     = {}
}

