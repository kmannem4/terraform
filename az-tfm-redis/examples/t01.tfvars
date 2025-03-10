location = "westus2"

tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "Platform Services",
  product         = "Platform Services",
  amnonecomponent = "shared",
  role            = "infrastructure-tf-unit-test",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}

# Azure Cache for Redis firewall filter rules are used to provide specific source IP access. 
# Azure Redis Cache access is determined based on start and end IP address range specified. 
# As a rule, only specific IP addresses should be granted access, and all others denied.
# "name" (ex. azure_to_azure or desktop_ip) may only contain alphanumeric characters and underscores
firewall_rules = {
  access_to_azure = {
    start_ip = "0.0.0.0"
    end_ip   = "255.255.255.255"
  }
}