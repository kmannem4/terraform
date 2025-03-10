# Purpose: Define the output variables for the Terraform configuration.
output "azurerm_windows_web_app_slot" {
  description = "Windows Web App Slot Service"
  value = {
    for k, v in azurerm_windows_web_app_slot.slot :
    k => {
      web_app_service_slot_id   = v.id
      web_app_service_slot_name = v.name
    }
  }
}
