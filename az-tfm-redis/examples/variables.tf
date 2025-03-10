variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Location of the resource group."
  type        = string
}

variable "subnet_id" {
  type        = string
  description = "subnet id of redis to be created"
  default     = null
}

variable "private_static_ip_address" {
  type        = string
  description = "private static ip address of redis to be created"
  default     = null
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = null
}