
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
action_group = {
  testactiongroup = {
    "name"       = "testactiongroup"
    "short_name" = "testag"
    "email_receivers" = [{
      "name"                    = "test_email_receiver"
      "email_address"           = "test@test.com"
      "use_common_alert_schema" = true
    }],
    "location" = "global"
  }
}
