variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure location."
  default     = "westus2"
  type        = string
}

variable "data_factory_config" {
  type = object({
    data_factory_name               = string                      # Name of the Azure Data Factory
    public_network_enabled          = bool                        # Boolean flag indicating whether the data factory is accessible from a public network
    managed_virtual_network_enabled = bool                        # Boolean flag indicating whether the data factory is connected to a managed virtual network
    identity                        = optional(string)            # Managed Service Identity (MSI) associated with the data factory, if any
    global_parameter = optional(object({                         # Global parameters for the data factory
      name  = optional(string)                                   # Name of the global parameter
      type  = optional(string)                                   # Type of the global parameter
      value = optional(string)                                   # Value of the global parameter
    }))
    github_configuration = optional(object({                     # GitHub configuration for the data factory
      account_name       = optional(string)                      # GitHub account name
      branch_name        = optional(string)                      # Branch name in the GitHub repository
      git_url            = optional(string)                      # URL of the GitHub repository
      repository_name    = optional(string)                      # Name of the GitHub repository
      root_folder        = optional(string)                      # Root folder within the GitHub repository
      publishing_enabled = optional(string)                      # Boolean flag indicating whether publishing is enabled
    }))
    vsts_configuration = optional(object({                       # VSTS (Visual Studio Team Services) configuration for the data factory
      account_name    = string                                  # VSTS account name
      branch_name     = optional(string)                        # Branch name in the VSTS repository
      project_name    = string                                  # VSTS project name
      repository_name = optional(string)                        # Name of the VSTS repository
      root_folder     = optional(string)                        # Root folder within the VSTS repository
    }))
  })
}


variable "tags" {
  validation {
    condition     = length(keys(var.tags)) <= 15
    error_message = "The number of tags must not exceed 15."
  }
}
