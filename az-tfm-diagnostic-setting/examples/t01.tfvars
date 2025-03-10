# Setting the location for Azure resources
location = "westus2"

# Assigning the resource ID of the Log Analytics Workspace
log_analytics_workspace_id = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"

# Defining tags to be applied to resources
tags = {
  charge-to       = "101-71200-5000-9500"               # Cost allocation or tracking
  environment     = "test"                              # Environment (e.g., dev, test, prod)
  application     = "Platform Services"                 # Application name
  product         = "Platform Services"                 # Product name
  amnonecomponent = "shared"                            # Component or service 
  role            = "infrastructure-tf-unit-test"       # Role or purpose
  managed-by      = "cloud.engineers@amnhealthcare.com" # Team or individual responsible for management
  owner           = "cloud.engineers@amnhealthcare.com" # Team or individual owning the resource
}
