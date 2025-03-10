output "action_group_id" {
  description = "The ID of the created action group."
  value = {
    for key, value in azurerm_monitor_action_group.action_group :
    key => value.id
  }
}

output "action_group_name" {
  description = "value of the action group name"
  value = {
    for key, value in azurerm_monitor_action_group.action_group :
    key => value.name
  }
}
