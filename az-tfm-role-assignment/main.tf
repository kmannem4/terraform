#---------------------------------------------------------
# Assign users, principals to management group, subscription and resource group
#----------------------------------------------------------
resource "azurerm_role_assignment" "role_assignment" {
  for_each = local.role_assignments

  principal_id       = each.value.principal_id
  scope              = each.value.scope
  role_definition_id = each.value.role_definition_id
}

#---------------------------------------------------------
# Role assignments as Entra ID role
#----------------------------------------------------------
resource "azuread_directory_role_assignment" "entra-role_assignment" {
  for_each = local.entra_id_role_assignments

  principal_object_id = each.value.principal_id
  role_id             = each.value.role_definition_id
}