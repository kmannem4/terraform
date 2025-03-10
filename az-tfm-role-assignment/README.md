# Introduction 
Terraform module to assign either a custom or built in role to a resource in Azure.

# Requirements
- terraform (~> 1.6)
- azuread (~> 2.46)
- azurerm (~> 3.71)

# Required Inputs
No required inputs.

# Optional Inputs

## app_registrations_by_client_id
Description: A map of Entra ID application registrations to reference in role assignments. The key is something unique to you. The value is the client ID (application ID) of the application registration.

Example Input:
```
app_registrations_by_client_id = {
  app1 = "00000000-0000-0000-0000-000000000001"
  app2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## app_registrations_by_display_name
Description: A map of Entra ID application registrations to reference in role assignments. The key is something unique to you. The value is the display name of the application registration.

Example Input:
```
app_registrations_by_display_name = {
  app1 = "App 1"
  app2 = "App 2"
}
```

Type: map(string)

## app_registrations_by_object_id 
Description: A map of Entra ID application registrations to reference in role assignments.
The key is something unique to you. The value is the object ID of the application registration.

Example Input:
```
app_registrations_by_object_id = {
  app1 = "00000000-0000-0000-0000-000000000001"
  app2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## app_registrations_by_principal_id
Description: A map of Entra ID application registrations to reference in role assignments.
The key is something unique to you. The value is the principal ID of the service principal backing the application registration.

Example Input:
```
app_registrations_by_principal_id = {
  app1 = "00000000-0000-0000-0000-000000000001"
  app2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## entra_id_role_definitions
Description: A map of Entra ID role definitions to reference in role assignments.
The key is something unique to you. The value is a built in or custom role definition name.

Example Input:
```
entra_id_role_definitions = {
  directory-writer     = "Directory Writer"
  global-administrator = "Global Administrator"
}
```
Type: map(string)

## groups_by_display_name
Description: A map of Entra ID groups to reference in role assignments.
The key is something unique to you. The value is the display name of the group.

Example Input:
```
groups_by_display_name = {
  group1 = "Group 1"
  group2 = "Group 2"
}
```
Type: map(string)

## groups_by_mail_nickname
Description: A map of Entra ID groups to reference in role assignments.
The key is something unique to you. The value is the mail nickname of the group.

Example Input:
```
groups_by_mail_nickname = {
  group1 = "group1-nickname"
  group2 = "group2-nickname"
}
```
Type: map(string)

## groups_by_object_id
Description: A map of Entra ID groups to reference in role assignments.
The key is something unique to you. The value is the object ID of the group.

Example Input:
```
groups_by_object_id = {
  group1 = "00000000-0000-0000-0000-000000000001"
  group2 = "00000000-0000-0000-0000-000000000002"
}
```
Type: map(string)

## role_assignments_for_entra_id
Description: Role assignments to be applied to Entra ID. This variable allows the assignment of Entra ID directory roles outside of the scope of Azure Resource Manager. This variable requires the entra_id_role_definitions variable to be populated.

role_assignments: (Required) The role assignments to be applied to the scope. <br>
role_definition: (Required) The key of the role definition as defined in the entra_id_role_definitions variable. <br>
users: (Optional) The keys of the users as defined in one of the users_by_... variables. <br>
groups: (Optional) The keys of the groups as defined in one of the groups_by_... variables. <br>
app_registrations: (Optional) The keys of the app registrations as defined in one of the app_registrations_by_... variables. <br>
system_assigned_managed_identities: (Optional) The keys of the system assigned managed identities as defined in one of the system_assigned_managed_identities_by_... variables. <br>
user_assigned_managed_identities: (Optional) The keys of the user assigned managed identities as defined in one of the user_assigned_managed_identities_by_... variables. <br>
any_principals: (Optional) The keys of the principals as defined in any of the [principal_type]_by_... variables. This is a convenience method that can be used in combination with or instrad of the specific principal type options. <br>

Example Input:
```
role_assignments_for_entra_id = {
  role_assignments    = {
    role_definition = "directory-writer"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}
```
Type:
```
map(object({
    role_assignments = map(object({
      role_definition                    = string
      users                              = optional(set(string), [])
      groups                             = optional(set(string), [])
      app_registrations                  = optional(set(string), [])
      system_assigned_managed_identities = optional(set(string), [])
      user_assigned_managed_identities   = optional(set(string), [])
      any_principals                     = optional(set(string), [])
    }))
  }))
```

## role_assignments_for_management_groups
Description: Role assignments to be applied to management groups. This is a convenience variable that avoids the need to find the resource id of the management group.

management_group_id: (Optional) The id of the management group (one of management_group_id or management_group_display_name must be supplied). <br>
management_group_display_name: (Optional) The display name of the management group. <br>
role_assignments: (Required) The role assignments to be applied to the scope. <br>
role_definition: (Required) The key of the role definition as defined in the role_definitions variable. <br>
users: (Optional) The keys of the users as defined in one of the users_by_... variables. <br>
groups: (Optional) The keys of the groups as defined in one of the groups_by_... variables. <br>
app_registrations: (Optional) The keys of the app registrations as defined in one of the app_registrations_by_... variables. <br>
system_assigned_managed_identities: (Optional) The keys of the system assigned managed identities as defined in one of the system_assigned_managed_identities_by_... variables. <br>
user_assigned_managed_identities: (Optional) The keys of the user assigned managed identities as defined in one of the user_assigned_managed_identities_by_... variables. <br>
any_principals: (Optional) The keys of the principals as defined in any of the [principal_type]_by_... variables. This is a convenience method that can be used in combination with or instrad of the specific principal type options. <br>

Example Input:
```
role_assignments_for_management_groups = {
  management_group_id = "mg-1-id"
  role_assignments    = {
    role_definition = "contributor"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}

role_assignments_for_management_groups = {
  management_group_display_name = "mg-1-display-name"
  role_assignments              = {
    role_definition = "contributor"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}
```
Type:
```
map(object({
    management_group_id           = optional(string, null)
    management_group_display_name = optional(string, null)
    role_assignments = map(object({
      role_definition                    = string
      users                              = optional(set(string), [])
      groups                             = optional(set(string), [])
      app_registrations                  = optional(set(string), [])
      system_assigned_managed_identities = optional(set(string), [])
      user_assigned_managed_identities   = optional(set(string), [])
      any_principals                     = optional(set(string), [])
    }))
  }))
```

## role_assignments_for_resource_groups
Description: Role assignments to be applied to resource groups. The resource group can be in the current subscription (default) or a subscription_id can be supplied to target a resource group in another subscription. This is a convenience variable that avoids the need to find the resource id of the resource group.

resource_group_name: (Required) The name of the resource group. <br>
subscription_id: (Optional) The id of the subscription. If not supplied the current subscription is used. <br>
role_assignments: (Required) The role assignments to be applied to the scope. <br>
role_definition: (Required) The key of the role definition as defined in the role_definitions variable. <br>
users: (Optional) The keys of the users as defined in one of the users_by_... variables. <br>
groups: (Optional) The keys of the groups as defined in one of the groups_by_... variables. <br>
app_registrations: (Optional) The keys of the app registrations as defined in one of the app_registrations_by_... variables. <br>
system_assigned_managed_identities: (Optional) The keys of the system assigned managed identities as defined in one of the system_assigned_managed_identities_by_... variables. <br>
user_assigned_managed_identities: (Optional) The keys of the user assigned managed identities as defined in one of the user_assigned_managed_identities_by_... variables. <br>
any_principals: (Optional) The keys of the principals as defined in any of the [principal_type]_by_... variables. This is a convenience method that can be used in combination with or instrad of the specific principal type options. <br>

Example Input:
```
role_assignments_for_resource_groups = {
  resource_group_name = "my-resource-group-name"
  role_assignments    = {
    role_definition = "contributor"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}
```

Type:
```
map(object({
    resource_group_name = string
    subscription_id     = optional(string, null)
    role_assignments = map(object({
      role_definition                    = string
      users                              = optional(set(string), [])
      groups                             = optional(set(string), [])
      app_registrations                  = optional(set(string), [])
      system_assigned_managed_identities = optional(set(string), [])
      user_assigned_managed_identities   = optional(set(string), [])
      any_principals                     = optional(set(string), [])
    }))
  }))
```

## role_assignments_for_resources
Description: Role assignments to be applied to resources. The resource is defined by the resource name and the resource group name. This variable only works with the current provider subscription. This is a convenience variable that avoids the need to find the resource id.

resouce_name: (Required) The names of the resource.<br>
resource_group_name: (Required) The name of the resource group.<br>
role_assignments: (Required) The role assignments to be applied to the scope.<br>
role_definition: (Required) The key of the role definition as defined in the role_definitions variable.<br>
users: (Optional) The keys of the users as defined in one of the users_by_... variables.<br>
groups: (Optional) The keys of the groups as defined in one of the groups_by_... variables.<br>
app_registrations: (Optional) The keys of the app registrations as defined in one of the app_registrations_by_... variables.<br>
system_assigned_managed_identities: (Optional) The keys of the system assigned managed identities as defined in one of the system_assigned_managed_identities_by_... variables.<br>
user_assigned_managed_identities: (Optional) The keys of the user assigned managed identities as defined in one of the user_assigned_managed_identities_by_... variables.<br>
any_principals: (Optional) The keys of the principals as defined in any of the [principal_type]_by_... variables. This is a convenience method that can be used in combination with or instrad of the specific principal type options.<br>

Example Input:
```
role_assignments_for_resources = {
  resource_name       = "my-resource-name"
  resource_group_name = "my-resource-group-name"
  role_assignments    = {
    role_definition = "contributor"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}
```

Type:
```
map(object({
    resource_name       = string
    resource_group_name = string
    role_assignments = map(object({
      role_definition                    = string
      users                              = optional(set(string), [])
      groups                             = optional(set(string), [])
      app_registrations                  = optional(set(string), [])
      system_assigned_managed_identities = optional(set(string), [])
      user_assigned_managed_identities   = optional(set(string), [])
      any_principals                     = optional(set(string), [])
    }))
  }))
```

## role_assignments_for_scopes
Description: Role assignments to be applied to specific scope ids. The scope id is the id of the resource, resource group, subscription or management group.

scope: (Required) The scope / id of the resource, resource group, subscription or management group.<br>
role_assignments: (Required) The role assignments to be applied to the scope.<br>
role_definition: (Required) The key of the role definition as defined in the role_definitions variable.<br>
users: (Optional) The keys of the users as defined in one of the users_by_... variables.<br>
groups: (Optional) The keys of the groups as defined in one of the groups_by_... variables.<br>
app_registrations: (Optional) The keys of the app registrations as defined in one of the app_registrations_by_... variables.<br>
system_assigned_managed_identities: (Optional) The keys of the system assigned managed identities as defined in one of the system_assigned_managed_identities_by_... variables.<br>
user_assigned_managed_identities: (Optional) The keys of the user assigned managed identities as defined in one of the user_assigned_managed_identities_by_... variables.<br>
any_principals: (Optional) The keys of the principals as defined in any of the [principal_type]_by_... variables. This is a convenience method that can be used in combination with or instrad of the specific principal type options.<br>

Example Input:
```
role_assignments_for_scopes = {
  scope            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group"
  role_assignments = {
    role_definition = "contributor"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}
```

Type:
```
map(object({
    scope = string
    role_assignments = map(object({
      role_definition                    = string
      users                              = optional(set(string), [])
      groups                             = optional(set(string), [])
      app_registrations                  = optional(set(string), [])
      system_assigned_managed_identities = optional(set(string), [])
      user_assigned_managed_identities   = optional(set(string), [])
      any_principals                     = optional(set(string), [])
    }))
  }))
```

## role_assignments_for_subscriptions
Description: Role assignments to be applied to subscriptions. This will default to the current subscription (default) or a subscription_id can be supplied to target another subscription. This is a convenience variable that avoids the need to find the resource id of the subscription.

subscription_id: (Optional) The id of the subscription. If not supplied the current subscription is used.<br>
role_assignments: (Required) The role assignments to be applied to the scope.<br>
role_definition: (Required) The key of the role definition as defined in the role_definitions variable.<br>
users: (Optional) The keys of the users as defined in one of the users_by_... variables.<br>
groups: (Optional) The keys of the groups as defined in one of the groups_by_... variables.<br>
app_registrations: (Optional) The keys of the app registrations as defined in one of the app_registrations_by_... variables.<br>
system_assigned_managed_identities: (Optional) The keys of the system assigned managed identities as defined in one of the system_assigned_managed_identities_by_... variables.<br>
user_assigned_managed_identities: (Optional) The keys of the user assigned managed identities as defined in one of the user_assigned_managed_identities_by_... variables.<br>
any_principals: (Optional) The keys of the principals as defined in any of the [principal_type]_by_... variables. This is a convenience method that can be used in combination with or instrad of the specific principal type options.<br>

Example Input:
```
role_assignments_for_subscriptions = {
  subscription_id     = "00000000-0000-0000-0000-000000000000"
  role_assignments    = {
    role_definition = "contributor"
    users = [
      "user1",
      "user2"
    ]
    groups = [
      "group1",
      "group2"
    ]
    app_registrations = [
      "app1",
      "app2"
    ]
    system_assigned_managed_identities = [
      "vm1",
      "vm2"
    ]
    user_assigned_managed_identities = [
      "user-assigned-managed-identity1",
      "user-assigned-managed-identity2"
    ]
  }
}
```

Type:
```
map(object({
    subscription_id = optional(string, null)
    role_assignments = map(object({
      role_definition                    = string
      users                              = optional(set(string), [])
      groups                             = optional(set(string), [])
      app_registrations                  = optional(set(string), [])
      system_assigned_managed_identities = optional(set(string), [])
      user_assigned_managed_identities   = optional(set(string), [])
      any_principals                     = optional(set(string), [])
    }))
  }))
```

## role_definitions
Description: A map of Azure Resource Manager role definitions to reference in role assignments. The key is something unique to you. The value is a built in or custom role definition name.

Example Input:
```
role_definitions = {
  owner       = "Owner"
  contributor = "Contributor"
  reader      = "Reader"
}
```

Type: map(string)

## system_assigned_managed_identities_by_client_id
Description: A map of system assigned managed identities to reference in role assignments. The key is something unique to you. The value is the client id of the identity.

Example Input:
```
system_assigned_managed_identities_by_client_id = {
  vm1 = "00000000-0000-0000-0000-000000000001"
  vm2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## system_assigned_managed_identities_by_display_name
Description: A map of system assigned managed identities to reference in role assignments. The key is something unique to you. The value is the display name of the identity / compute instance.

Example Input:
```
system_assigned_managed_identities_by_display_name = {
  vm1 = "VM 1"
  vm2 = "VM 2"
}
```

Type: map(string)

## system_assigned_managed_identities_by_principal_id
Description: A map of system assigned managed identities to reference in role assignments. The key is something unique to you. The value is the principal id of the underying service principalk of the identity.

Example Input:
```
system_assigned_managed_identities_by_principal_id = {
  vm1 = "00000000-0000-0000-0000-000000000001"
  vm2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## user_assigned_managed_identities_by_client_id
Description: A map of system assigned managed identities to reference in role assignments. The key is something unique to you. The value is the client id of the identity.

Example Input:
```
user_assigned_managed_identities_by_client_id = {
  mi1 = "00000000-0000-0000-0000-000000000001"
  mi2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## user_assigned_managed_identities_by_display_name
Description: A map of system assigned managed identities to reference in role assignments. The key is something unique to you. The value is the display name of the identity.

Example Input:
```
user_assigned_managed_identities_by_display_name = {
  mi1 = "User Identity 1"
  mi2 = "User Identity 2"
}
```

Type: map(string)

## user_assigned_managed_identities_by_principal_id
Description: A map of system assigned managed identities to reference in role assignments. The key is something unique to you. The value is the principal id of the underying service principalk of the identity.

Example Input:
```
user_assigned_managed_identities_by_principal_id = {
  mi1 = "00000000-0000-0000-0000-000000000001"
  mi2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## user_assigned_managed_identities_by_resource_group_and_name
Description: (Optional) A map of user assigned managed identities to reference in role assignments. The key is something unique to you. The values are:

resource_group_name: The name of the resource group the identity is in.<br>
name: The name of the identity.<br>

Example Input:
```
user_assigned_managed_identities_by_resource_group_and_name = {
  my-identity-1 = {
    resource_group_name = "my-rg-1"
    name                = "my-identity-1"
  }
  my-identity-2 = {
    resource_group_name = "my-rg-2"
    name                = "my-identity-2"
  }
}
```

Type:
```
map(object({
    resource_group_name = string
    name                = string
  }))
```

## users_by_employee_id
Description: A map of Entra ID users to reference in role assignments. The key is something unique to you. The value is the employee ID of the user.

Example Input:
```
users_by_employee_id = {
  my-user-1 = "1234567890"
  my-user-2 = "0987654321"
}
```

Type: map(string)

## users_by_mail
Description: A map of Entra ID users to reference in role assignments. The key is something unique to you. The value is the mail address of the user.

Example Input:
```
users_by_mail = {
  user1 = "user.1@example.com"
  user2 = "user.2@example.com"
}
```

Type: map(string)

## users_by_mail_nickname
Description: A map of Entra ID users to reference in role assignments. The key is something unique to you. The value is the mail nickname of the user.

Example Input:
```
users_by_mail_nickname = {
  user1 = "user1-nickname"
  user2 = "user2-nickname"
}
```

Type: map(string)

## users_by_object_id
Description: A map of Entra ID users to reference in role assignments. The key is something unique to you. The value is the object ID of the user.

Example Input:
```
users_by_object_id = {
  user1 = "00000000-0000-0000-0000-000000000001"
  user2 = "00000000-0000-0000-0000-000000000002"
}
```

Type: map(string)

## users_by_user_principal_name
Description: A map of Entra ID users to reference in role assignments. The key is something unique to you. The value is the user principal name (UPN) of the user.

Example Input:
```
users_by_user_principal_name = {
  user1 = "user1@example.com"
  user2 = "user2@example.com"
}
```

Type: map(string)

# Outputs

## all_principals
Description: A map of all principals. The key is the key you supplied and the value is the principal id (object id) of the user, group, service principal, or managed identity.

## app_registrations
Description: A map of Entra ID application registrations. The key is the key you supplied and the value is the principal id (object id) of the service principal backing the application registration.

## entra_id_role_assignments
Description: A map of Entra ID role assignments. The key is the key you supplied and the value is the role assignment details:

role_definition_id: The role definition template id of the role assignment.<br>
principal_id: The principal id (object id) of the user, group, service principal, or managed identity the role assignment is for.<br>

## entra_id_role_definitions
Description: A map of Entra ID role definitions. The key is the key you supplied and the value is the role definition template id.

## groups
Description: A map of Entra ID groups. The key is the key you supplied and the value is the principal id (object id) of the group.

## role_assignments
Description: A map of Azure Resource Manager role assignments. The key is the key you supplied and the value is the role assignment details:

role_definition_id: The role definition id of the role assignment.<br>
principal_id: The principal id (object id) of the user, group, service principal, or managed identity the role assignment is for.<br>
scope: The scope of the role assignment.<br>

## role_defintions
Description: A map of Azure Resource Manager role definitions. The key is the key you supplied and the value consists of is the role definition id and the allowed scopes.

## system_assigned_managed_identities
Description: A map of system assigned managed identities. The key is the key you supplied and value is the principal id (object id) of the service principal backing system assigned managed identity.

## user_assigned_managed_identities
Description: A map of user assigned managed identities. The key is the key you supplied and value is the principal id (object id) of the service principal backing user assigned managed identity.

## users
Description: A map of Entra ID users. The key is the key you supplied and the value is the principal id (object id) of the user.

# Module Usage
This module enables you to create role assignments at multiple scopes for multiple principals with multiple methods of finding the principal id.

## Example Scenario - Assign a User Managed Identity Contributor rights to Serivce bus

The following steps in example to using this module:
- Create resource group
- Create the user assigned identity
- Create the service bus namespace
- Define the principal
  - user_assigned_managed_identities_by_principal_id: Find user assigned managed identities by their principal id.
- Define the role definitions
  - role_definitions: Find Azure Resource Manager role definitions by their name
- Map the principals to the role definitions at a specific scope
  - role_assignments_for_resources: Map principals to role definitions at the resource scope. This only works in the scope of the current subscription. Use the role_assignments_for_scopes to apply resource scope role assignments in other subscription.

NOTE: The module does not create the principals or role definitions, it will be created in example scenario. Module only creates the role assignments.

NOTE: Ensure service principal of the "AMN_TF_Test" service connection has "Group.Read.All", "Application.Read.All", "User.Read.All" and "Directory.Read.All" API Permissions under Microsoft Graph and grant consent.

```
module "rg" {
  source                  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Shared%20Services/_git/amn-az-tfm-resourcegroup?ref=54b1237ee3187764c78ba30643d3fc5cb7469ec1"
  resource_group_name     = var.resource_group_name
  location                = var.location
  tags                    = var.tags
}

module "servicebus" {
  depends_on = [module.rg]
  source                        = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Shared%20Services/_git/amn-az-tfm-service-bus?ref=5ffc539dd22ac24bc8ac40332ac21fe54afefd46"
  resource_group_name           = module.rg.resource_group_name
  tags                          = var.tags
  queue_vars                    = {}
  topic_vars                    = {}
  servicebus_local_auth_enabled = null
  servicebus_name               = var.servicebus_name
  servicebus_location           = var.servicebus_location
  servicebus_sku_name           = var.servicebus_sku_name
  servicebus_zone_redundant     = null
  servicebus_capacity           = null
  premium_messaging_partitions  = null
  minimum_tls_version           = null
  public_network_access_enabled = null
  servicebus_authorization_vars = {}
}

module "user_assigned_identity" {
  depends_on = [module.rg]
  source                      = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Shared%20Services/_git/amn-az-tfm-user-assigned-identity?ref=e6dbebdf01d0a81aca2b0fcb9d0d7be17cb46b32"
  resource_group_name         = module.rg.resource_group_name
  location                    = var.location
  user_assigned_identity_name = var.mgid
  tags                        = var.tags
}

module "role_assignments" {
  depends_on = [module.servicebus, module.user_assigned_identity]
  source = "../../"
  // source = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Shared%20Services/_git/amn-az-tfm-role-assignment"
  //user_assigned_managed_identities_by_display_name = {
  //  mi1 =  module.user_assigned_identity.mi_id # Note we are using the same key as the system assigned managed identity, this principal will get precedence over the system assigned managed identity. The system assigned managed identity will be ignored.
  //}
  user_assigned_managed_identities_by_principal_id = {
    mi1 =  module.user_assigned_identity.mi_principal_id
  }
  role_definitions = {
    role1 = var.role
  }
  role_assignments_for_resources = {
    example1 = {
      resource_name       = module.servicebus.servicebus_namespace_name
      resource_group_name = module.user_assigned_identity.mi_tenant_resource_group_name
      role_assignments = {
        role_assignment_1 = {
          role_definition = "role1"
          any_principals  = ["mi1"]
        }
      }
    }
  }
}
```
It will deploy the resources in T01 environment with below (examples/RoleAssignmentForResource/t01.tfvars) var file, when PR (pipelines/amn_az_tfm_role_assignment_pr.yaml) triggered, apply validation unit tests will run after resource created, and it automatically teardown all resources after tests run successfully.

```
resource_group_name        = "co-wus2-roleassignments-rg-t01"
location                   = "westus2"
servicebus_location        = "westus2"
servicebus_name            = "co-wus2-amnoneshared-svcb-t01" #TODO: Update resource name for testing
servicebus_sku_name        = "Standard"
mgid                       = "co-wus2-module-test-mgid-t01"
role                       = "contributor"
tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "amnone",
  product         = "AMNOne",
  amnonecomponent = "shared",
  role            = "infrastructure",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}
```

# Resources

- azurerm_role_assignment (resource)

# Unit Tests
- [Test cases](examples\RoleAssignmentForResource\tests\apply_validation_tests\main.tftest.hcl)
  - Role Assignment is compared with given Role defintion's role assignment.
  - Role Assignment managed identity is compared with the given assigned role.