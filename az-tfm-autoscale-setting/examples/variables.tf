# Variable to define the Azure location for resources
variable "location" {
  # Default location is set to "westus2"
  default = "westus2"
}

# Variable to define tags to be added to all resources
variable "tags" {
  description = "A map of tags to add to all resources"
  # Tags are defined as a map of key-value pairs
  type = map(string)
  # Default value is an empty map
  default = {}
}
