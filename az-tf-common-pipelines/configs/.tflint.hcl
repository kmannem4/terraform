plugin "azurerm" {
  enabled = true
  version = "0.25.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
  version = "0.6.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}