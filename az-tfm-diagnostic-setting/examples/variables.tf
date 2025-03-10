# Variable to define the Azure location for resources
variable "location" {
  # Default location is set to "westus2"
  default = "westus2"
}

# Variable to store the Resource ID of the Log Analytics Workspace
variable "log_analytics_workspace_id" {
  description = "Resource ID of LAW"
  type        = string
}

# Variable to define a list of containers with their access levels
variable "containers_list" {
  description = "List of containers to create and their access levels."
  # The list consists of objects with "name" and "access_type" attributes
  type = list(object({ name = string, access_type = string }))
  # Default value is an empty list
  default = []
}

# Variable to define tags to be added to all resources
variable "tags" {
  description = "A map of tags to add to all resources"
  # Tags are defined as a map of key-value pairs
  type = map(string)
  # Default value is an empty map
  default = {}
}
