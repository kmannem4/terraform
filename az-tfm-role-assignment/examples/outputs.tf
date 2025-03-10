output "all_principals" {
  value = module.role_assignments.all_principals
}

output "app_registrations" {
  value = module.role_assignments.app_registrations
}

output "entra_id_role_assignments" {
  value = module.role_assignments.entra_id_role_assignments
}

output "entra_id_role_definitions" {
  value = module.role_assignments.entra_id_role_definitions
}

output "groups" {
  value = module.role_assignments.groups
}

output "role_assignments" {
  value = module.role_assignments.role_assignments
}

output "role_defintions" {
  value = module.role_assignments.role_defintions
}

output "system_assigned_managed_identities" {
  value = module.role_assignments.system_assigned_managed_identities
}

output "user_assigned_managed_identities" {
  value = module.role_assignments.user_assigned_managed_identities
}

output "users" {
  value = module.role_assignments.users
}


locals {
  role_assignments = {
    for idx, key in keys(module.role_assignments.role_assignments) :
    (idx + 1) => {
      value = module.role_assignments.role_assignments[key].role_definition_id
    }
  }

  role_defintions = {
    for idx, key in keys(module.role_assignments.role_defintions) :
    (idx + 1) => {
      value = module.role_assignments.role_defintions[key].role_definition_id
    }
  }

  boolean_map = {
    for idx, key in keys(module.role_assignments.role_defintions) :
    (idx + 1) => {
      value = true
    }
  }
}

