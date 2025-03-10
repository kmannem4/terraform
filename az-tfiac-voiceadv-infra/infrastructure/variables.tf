variable "rgname" {
  description = "Resource Group Name"
  default     = "co-wus2-voiceadv-rg-q01"
  type        = string
}

variable "location" {
  description = "Azure location"
  default     = "West US2"
  type        = string
}

variable "vnetname" {
  description = "Virtual Network Name"
  default     = "co-wus2-voiceadv-vnet-q01"
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  default     = ["10.100.2.0/26"]
  type        = list(string)
}
variable "environment" {
  description = "Environment name"
  default     = "qa"
  type        = string
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}

variable "vmname" {
  description = "Map of vm names"
  type = map(object({
    vm_name = string
  }))
}
### variable for vmnames to increament by 1
variable "vm_base_name" {
  description = "basename of vm"
  type = string
  default = "co-wus2-voiceadv-docker-vm"
}
variable "initial_index" {
  description = "Initial index for VM instances"
  type        = number
  default     = 1
}
variable "vm_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 3  # Set the desired number of VM instances
}
variable "privatedns_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 2  # Set the desired number of privatedns_count
}
variable "vm_suffix" {
  description = "Suffix for VM instances"
  type        = string
  default     = "-q01"
}
variable "db_name" {
  description = "Name of the database that will be created on the flexible instance. If this is specified then a database will be created as a part of the instance provisioning process."
  type        = string
  default     = null
}
######################################
variable "data_disks" {
  description = "Configuration for data disks."
  type = list(object({
    name                 = string
    storage_account_type = string
    disk_size_gb         = number
    # Add other required attributes here
  }))
}

variable "admin_username" {
  description = "Admin user name for accissing VM"
  default     = "Azureuser"
  type        = string
}
variable "admin_pass" {
  description = "admin pass"
  default     = "Azure@1234"
  type        = string
}

variable "admin_ssh_key" {
  description = "SSH public key for authentication"
  default     = "ssh-rsa ...generated-by-azure"
  type        = string
}

variable "ssh_key_environment" {
  description = "Environment name for SSH key"
  default     = "qa"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  default     = "co-wus2-voiceadv-sshkey-vm-q01"
  type        = string
}
variable "bastionhost_name" {
  description = "Bastionhost"
  default     = "co-wus2-voiceadv-basthost-q01"
  type        = string
}
variable "basthost_publicip" {
  description = "publicip for bastionhost"
  default     = "co-wus2-voiceadv-publicip-q01"
  type        = string
}
variable "keyvault_name" {
  description = "Name of the Azure Key Vault"
}

variable "use_keyvault_admin_username" {
  description = "Flag to indicate whether to use Key Vault for admin username"
  default     = true
}

variable "admin_username_keyvault_secret_name" {
  description = "Name of the secret containing admin username in Key Vault"
  default     = "test"
}

variable "use_keyvault_admin_password" {
  description = "Flag to indicate whether to use Key Vault for admin password"
  default     = true
}

variable "admin_password_keyvault_secret_name" {
  description = "Name of the secret containing admin password in Key Vault"
  default     = "test"
}

variable "db_servers_name" {
  description = "Names of the PostgreSQL instances"
  type = map(object({
    db_server_name = string
  }))
}

/**variable "db_server_name" {
  description = "Names of the PostgreSQL instances"
  type        = string
  default     = "co-wus2-voiceadv-sql-q01"
}**/


variable "admin_username_secret_name" {
  description = "Name of the secret containing admin username in Key Vault"
  type        = string
}
variable "admin_password_secret_name" {
  description = "Name of the secret containing admin password in Key Vault"
  type        = string
}
variable "storage_account_name" {
  description = "Name of the secret containing admin password in Key Vault"
  type        = string
}
variable "sa_container" {
  description = "Name of the secret containing admin password in Key Vault"
  type        = string
}
variable "sa_privateendpoint" {
  description = "Name of the secret containing admin password in Key Vault"
  type        = string
}
variable "keyvault_id" {
  description = "Keyvault id"
  type        = string
}
variable "db_engine" {
  description = "Database engine version for the Azure database instance."
  type        = string
  default     = "12"
}
variable "db_server_sku" {
  description = "Instance SKU, see comments above for guidance"
  type        = string
  default     = "Standard_E8ds_v4"
}
variable "db_allocated_storage" {
  description = "The max storage allowed for the PostgreSQL Flexible Server. Possible values (MB) are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216."
  type        = number
  default     = 65536
}
variable "db_password" {
  description = "Password for the master database user."
  type = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The db_password value must be at least 8 characters in length."
  }
}

variable "db_username" {
  description = "db username"
  type        = string
}


variable "db_private_dns_zone_id" {
  description = "Map the dns names to postgress db"
  type        = string
  default     = "example.com" # Replace with an appropriate DNS zone name
}

variable "db_private_dns_zone_id1" {
  description = "Map the dns names to postgress db"
  type        = string
  default     = "example.com" # Replace with an appropriate DNS zone name
}
## pgsql sandbox ##
variable "db_private_dns_zone_id2" {
  description = "Map the dns names to postgress db"
  type        = string
  default     = "example.com" # Replace with an appropriate DNS zone name
}
variable "postgresql_private_endpoint" {
  description = "postgresql_private_endpoint"
  type        = string
  default     = "postgress-endpoint"
}
variable "subscription_id" {
  description = "subscription value"
  type = string
  default = "QA"
}
variable "source_address_prefix" {
  description = "nsg source address"
  type = string
  default = "10.103.0.32/27"
}

variable "instances_count" {
  description = "number of instances"
  type = string
  default = "2"
  
}
variable "BitbucketIP" {
  description = "Bitbucket ips to be whitelisted"
  type = string
  default = "34.199.54.113,34.232.25.90,34.232.119.183,34.236.25.177,35.171.175.212,52.54.90.98,52.202.195.162,52.203.14.55,52.204.96.37,34.218.156.209,34.218.168.212,52.41.219.63,35.155.178.254,35.160.177.10,34.216.18.129,3.216.235.48,34.231.96.243,44.199.3.254,174.129.205.191,44.199.127.226,44.199.45.64,3.221.151.112,52.205.184.192,52.72.137.240"
}

variable "app_insights_name" {
  description = "The name of the Application Insights resource."
  type        = string
}

variable "application_type" {
  description = "The type of the Application Insights web or app."
  type        = string
}
variable "workspace_id" {
  description = "log analytics workspace"
  type        = string
}

variable "os_flavor" {
  description = "Specify the flavor of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux`"
  default     = "linux"
}
variable "public_network_access_enabled"{
  type = bool
  default = false
}
variable "create_key_vault" {
  type = bool
  default = true
}
variable "geo_redundant_backup_enabled" {
  description = "Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server."
  type        = bool
  default     = false
}
variable "db_collation" {
  description = "Specifies the Collation for the Database."
  type        = string
  default     = "en_US.UTF8"
}
variable "db_charset" {
  description = "Specifies the Charset for the database."
  type        = string
  default     = "UTF8"
}
variable "db_timeouts" {
  type = object({
    create = optional(string, null)
    delete = optional(string, null)
    update = optional(string, null)
    read   = optional(string, null)
  })
  description = "Map of timeouts that can be adjusted when executing the module. This allows you to customize how long certain operations are allowed to take before being considered to have failed."
  default = {
    db_timeouts = {}
  }
}
variable "db_create_mode" {
  description = "The creation mode which can be used to restore or replicate existing servers."
  type        = string
  validation {
    condition     = contains(["Default", "Replica", "GeoRestore", "PointInTimeRestore"], var.db_create_mode)
    error_message = "The db_create_mode must be \"Default\",\"Replica\",\"GeoRestore\", or \"PointInTimeRestore\"."
  }
  default = "Default"
}
variable "db_firewall_rules" {
  description = "Map of IP ranges that  will create firewall rules for the server to access those addresses"
  type = list(object({
    name = string
    start_ip_address = optional(string)
    end_ip_address = optional(string) 
  }))
  default = [ ]

}
variable "db_parameters" {
  type = object({
    postgres = optional(object({
      max_connections = optional(object({
        value = optional(string, "256")
      }))
      shared_buffers = optional(object({
        value = optional(string, "6291456")
      }))
      huge_pages = optional(object({
        value = optional(string, "on")
      }))
      temp_buffers = optional(object({
        value = optional(string, "4000")
      }))
      work_mem = optional(object({
        value = optional(string, "2097151")
      }))
      maintenance_work_mem = optional(object({
        value = optional(string, "512000")
      }))
      autovacuum_work_mem = optional(object({
        value = optional(string, "-1")
      }))
      effective_io_concurrency = optional(object({
        value = optional(string, "32")
      }))
      wal_level = optional(object({
        value = optional(string, "logical")
      }))
      wal_buffers = optional(object({
        value = optional(string, "512")
      }))
      cpu_tuple_cost = optional(object({
        value = optional(string, "0.03")
      }))
      effective_cache_size = optional(object({
        value = optional(string, "350000000")
      }))
      random_page_cost = optional(object({
        value = optional(string, "1.1")
      }))
      checkpoint_timeout = optional(object({
        value = optional(string, "3600")
      }))
      checkpoint_completion_target = optional(object({
        value = optional(string, "0.9")
      }))
      checkpoint_warning = optional(object({
        value = optional(string, "1")
      }))
      log_min_messages = optional(object({
        value = optional(string, "error")
      }))
      log_min_error_statement = optional(object({
        value = optional(string, "error")
      }))
      autovacuum = optional(object({
        value = optional(string, "on")
      }))
      autovacuum_max_workers = optional(object({
        value = optional(string, "10")
      }))
      autovacuum_vacuum_cost_limit = optional(object({
        value = optional(string, "3000")
      }))
      datestyle = optional(object({
        value = optional(string, "ISO, DMY")
      }))
      lc_monetary = optional(object({
        value = optional(string, "en_US.utf-8")
      }))
      lc_numeric = optional(object({
        value = optional(string, "en_US.utf-8")
      }))
      azure_extensions= optional(object({
        value = optional(string, "CUBE")
      }))
      default_text_search_config = optional(object({
        value = optional(string, "pg_catalog.english")
      }))
      max_locks_per_transaction = optional(object({
        value = optional(string, "64")
      }))
      max_wal_senders = optional(object({
        value = optional(string, "5")
      }))
      min_wal_size = optional(object({
        value = optional(string, "8192")
      }))
      max_wal_size = optional(object({
        value = optional(string, "65536")
      }))
    }))
    })
  default = {
    postgres = {
      autovacuum                   = {}
      autovacuum_max_workers       = {}
      autovacuum_vacuum_cost_limit = {}
      autovacuum_work_mem          = {}
      checkpoint_completion_target = {}
      checkpoint_timeout           = {}
      checkpoint_warning           = {}
      cpu_tuple_cost               = {}
      datestyle                    = {}
      default_text_search_config   = {}
      effective_cache_size         = {}
      effective_io_concurrency     = {}
      huge_pages                   = {}
      lc_monetary                  = {}
      lc_numeric                   = {}
      log_min_error_statement      = {}
      log_min_messages             = {}
      maintenance_work_mem         = {}
      max_connections              = {}
      max_locks_per_transaction    = {}
      max_wal_senders              = {}
      max_wal_size                 = {}
      min_wal_size                 = {}
      random_page_cost             = {}
      shared_buffers               = {}
      temp_buffers                 = {}
      wal_buffers                  = {}
      wal_level                    = {}
      work_mem                     = {}
    }
  }
  description = "Intel Cloud optimizations for Xeon processors"
}