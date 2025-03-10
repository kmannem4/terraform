variable "location" {
  description = "Azure location."
  default     = "westus2"
  type        = string
}

variable "data_factory_config" {
  type = object({
    data_factory_name               = string
    public_network_enabled          = bool
    managed_virtual_network_enabled = bool
    identity                        = optional(string)
    global_parameter = optional(object({
      name  = optional(string)
      type  = optional(string)
      value = optional(string)
    }))
    github_configuration = optional(object({
      account_name       = optional(string)
      branch_name        = optional(string)
      git_url            = optional(string)
      repository_name    = optional(string)
      root_folder        = optional(string)
      publishing_enabled = optional(string)
    }))
    vsts_configuration = optional(object({
      account_name    = string
      branch_name     = optional(string)
      project_name    = string
      repository_name = optional(string)
      root_folder     = optional(string)
    }))
  })
}

variable "tags" {
  validation {
    condition     = length(keys(var.tags)) <= 15
    error_message = "The number of tags must not exceed 15."
  }
}
