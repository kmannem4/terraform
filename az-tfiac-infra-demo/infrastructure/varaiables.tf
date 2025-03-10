variable "rgname" {
  description = "Resource Group Name"
  default     = "defaultrg"
  type        = string
}
variable "location" {
  description = "Azure location"
  default     = "West US2"
  type        = string
}

variable "storagename" {
  description = "Storage Account Name"
  default     = "defaultsa"
  type        = string
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}
