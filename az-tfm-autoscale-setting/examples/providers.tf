# Terraform block to configure settings for the entire project
terraform {
  # Specify the minimum required version of Terraform
  required_version = ">=1.3"

  # Define required providers for this project
  required_providers {
    # Azure provider configuration
    azurerm = {
      # Source of the provider (from the HashiCorp registry)
      source = "hashicorp/azurerm"
      # Version constraint for the Azure provider (>= 4.0)
      version = ">= 4.0"
    }
    # Random provider configuration
    random = {
      # Source of the provider (from the HashiCorp registry)
      source = "hashicorp/random"
      # Version constraint for the random provider (3.3.2)
      version = "3.3.2"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  # Enable provider features (empty block for default features)
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

# Configure the random provider (no specific configuration needed)
provider "random" {}
