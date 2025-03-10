variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Location of the resource group."
  type        = string
}

