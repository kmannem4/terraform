terraform {
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    
    }
  }
}

provider "azurerm" {
  features {}
}


module "az-resource-group" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-resourcegroup?ref=tags/v1.0.0"
  # Resource Group Variables
  resource_group_name     = var.rgname
  location = var.location

  tags = {
    application   = "Infrastructure"
    product       = "Medefis"
    charge-to     = "101-71200-5000-9500"
    environment   = "dev"
    managed-by    = "cloud.engineers@amnhealthcare.com"
    owner         = "cloud.engineers@amnhealthcare.com"
  } 
}
