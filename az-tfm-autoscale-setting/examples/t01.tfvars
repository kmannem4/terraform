# Setting the location for Azure resources
location = "westus2"

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
