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

/**
provider "azurerm" {

  features {}  
  alias           = "sharedservice"
  subscription_id = "43c5a646-c00c-4c59-a332-df854c5dd08c"

}
**/

/**
locals {
  authorized_ip_adress = "10.0.0.1,10.0.0.2,10.0.0.3"
}

output "authorized_ip_adress" {
  value = local.authorized_ip_adress
}
**/


module "az-resource-group" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-resourcegroup?ref=tags/v1.0.0"
                      
  # Resource Group Variables

  resource_group_name     = var.rgname
  location = var.location

 tags = {
    application   = "Infrastructure"
    product       = "Infrastructure"
    charge-to     = "101-71200-5000-9500"
    environment   = "dev"
    managed-by    = "cloud.engineers@amnhealthcare.com"
    owner         = "cloud.engineers@amnhealthcare.com"
  } 
}

/**
data "azurerm_key_vault" "KV" {
  name                = "kvtestvaultaccess"
  resource_group_name = var.rgname
}

data "azurerm_key_vault_secret" "example" {
  name         = "test"
  key_vault_id = data.azurerm_key_vault.KV.id
}**/


/**
module "azure_postgress" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-postgress?ref=tags/v1.0.0"
  resource_group_name = var.rgname
  location = var.location
  db_instance_names = [ "instance1","instance2" ]
  db_names = default = [ "db1","db2" ]
    
}
**/

/**data "azurerm_log_analytics_workspace" "example" {
  name                = "testlaw-for-tfautomation"
  resource_group_name = "testrg-for-tfautomation"
}
**/

/** data "azurerm_log_analytics_workspace" "example" {

  //subscription_id     = "43c5a646-c00c-4c59-a332-df854c5dd08c"
  provider            = azurerm.sharedservice
  name                = "amn-co-wus2-enterprisemonitor-loga-d01"
  resource_group_name = "co-wus2-enterprisemonitor-rg-s01"
  
}**/

/**resource "azurerm_application_insights" "example" {
  name                = "test-appinsights"
  location            = module.az-resource-group.location
  resource_group_name = module.az-resource-group.resource_group_name
  workspace_id        = data.azurerm_log_analytics_workspace.example.id
  application_type    = "web"
}**/





module "vnet" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-virtual-network?ref=tags/v1.0.0"

  create_resource_group         = false
  resource_group_name           = module.az-resource-group.resource_group_name
  vnetwork_name                 = "testvnet-dev"
  location                      = module.az-resource-group.location
  vnet_address_space            = ["10.1.0.0/16"]
  create_network_watcher         = false



  # Adding Standard DDoS Plan, and custom DNS servers (Optional)
  #create_ddos_plan = true

  # Multiple Subnets, Service delegation, Service Endpoints, Network security groups
  # These are default subnets with required configuration, check README.md for more details
  # NSG association to be added automatically for all subnets listed here.
  # First two address ranges from VNet Address space reserved for Gateway And Firewall Subnets.
  # ex.: For 10.1.0.0/16 address space, usable address range start from 10.1.2.0/24 for all subnets.
  # subnet name will be set as per Azure naming convention by defaut. expected value here is: <App or project name>
  subnets = var.subnets

  # Adding TAG's to your Azure resources (Required)
  tags = {
    charge-to =  "101-71200-5000-9500",
    environment = "dev",
    application = "infrastructure",
    product = "infrastructure"

  }
}



## KV creation 
resource "azurerm_key_vault" "keyv" {
  #checkov:skip=CKV2_AZURE_42:checkov bug skipping
  #checkov:skip=CKV2_AZURE_32:checkov bug skipping 
  #checkov:skip=CKV_SECRET_6:checkov bug skipping 
  #checkov:skip=CKV_AZURE_130:checkov bug skipping 
  #checkov:skip=CKV_AZURE_128:checkov bug skipping 
  #checkov:skip=CKV_AZURE_109:checkov bug skipping 
  #checkov:skip=CKV_AZURE_110:checkov bug skipping 
  #checkov:skip=CKV_AZURE_42:checkov bug skipping 
  name                          = "testingkeyv"
  location                      = var.location
  resource_group_name           = module.az-resource-group.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"

  enable_rbac_authorization     = true
  
  purge_protection_enabled = false

  public_network_access_enabled   = false

  tags = {
    application   = "Infrastructure"
    product       = "Infrastructure"
    charge-to     = "101-71200-5000-9500"
    environment   = "dev"
    managed-by    = "cloud.engineers@amnhealthcare.com"
    owner         = "cloud.engineers@amnhealthcare.com"
  } 

}

data "azurerm_client_config" "current" {}

resource "azurerm_private_endpoint" "kv_endpt_s1" {
  
  name                = lower("${azurerm_key_vault.keyv.name}-ep")
  location            = var.location
  resource_group_name = module.az-resource-group.resource_group_name
  subnet_id           = module.vnet.subnet_ids[0]

  private_service_connection {
    name                           = "${azurerm_key_vault.keyv.name}--pl"
    private_connection_resource_id = azurerm_key_vault.keyv.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

}



/**
module "storage" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-storage-account?ref=tags/v1.0.0"

  create_resource_group = false
  resource_group_name   = module.az-resource-group.name
  location              = module.az-resource-group.location
  storage_account_name  = var.storagename

  # To enable advanced threat protection set argument to `true`
  enable_advanced_threat_protection = true

  tags = {
    charge-to =  "101-71200-5000-9500",
    environment = "dev",
    application = "infrastructure",
    product = "infrastructure"

  }
}

**/

/**3/5/2024
module "virtual-machine" {
  count = 2

  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-virtual-machine?ref=tags/v1.0.0"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = module.az-resource-group.resource_group_name
  location             = module.az-resource-group.location
  virtual_network_name = "testvnet-dev"
  subnet_name          = "snet-pvt"
  virtual_machine_name = "win-machine-${count.index}"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for WindowsServer, MSSQLServer.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # This module creates a random admin password if `admin_password` is not specified
  # Specify a valid password with `admin_password` argument to use your own password 
  os_flavor                 = "windows"
  windows_distribution_name = "windows2019dc"
  virtual_machine_size      = "Standard_A2_v2"
  admin_username            = "azureadmin"
  admin_password            = "P@$$w0rd1234!"
  instances_count           = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = false

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  nsg_inbound_rules = [
    {
      name                   = "rdp"
      destination_port_range = "3389"
      source_address_prefix  = "*"
    },
    {
      name                   = "http"
      destination_port_range = "80"
      source_address_prefix  = "*"
    },
  ]

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = false

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  #log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  #deploy_log_analytics_agent                 = true
  #log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id
  #log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key

  # Adding additional TAG's to your Azure resources
  tags = {
    charge-to =  "101-71200-5000-9500",
    environment = "dev",
    application = "infrastructure",
    product = "infrastructure"
  }
}
3/5/24**/


/**
module "linux-virtual-machine" {
  #checkov:skip=CKV_TF_1:checkov bug skipping
  source = "git::ssh://git@ssh.dev.azure.com/v3/AMNEngineering/Shared%20Services/amn-az-tfm-virtual-machine?ref=tags/v1.0.0"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = module.az-resource-group.name
  location             = module.az-resource-group.location
  virtual_network_name = "testvnet-dev"
  subnet_name          = "snet-pvt"
  virtual_machine_name = "lnx-machine"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for WindowsServer, MSSQLServer.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # This module creates a random admin password if `admin_password` is not specified
  # Specify a valid password with `admin_password` argument to use your own password 
  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count           = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = false

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  nsg_inbound_rules = [
    {
      name                   = "ssh"
      destination_port_range = "22"
      source_address_prefix  = "*"
    },
    {
      name                   = "http"
      destination_port_range = "80"
      source_address_prefix  = "*"
    },
  ]

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = false

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  #log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  #deploy_log_analytics_agent                 = true
  #log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id
  #log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key

  # Adding additional TAG's to your Azure resources
  tags = {
    charge-to =  "101-71200-5000-9500",
    environment = "dev",
    application = "infrastructure",
    product = "infrastructure"
  }
}**/

