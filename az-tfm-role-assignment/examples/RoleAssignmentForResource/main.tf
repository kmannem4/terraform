// resource "random_string" "resource_name" {
//   length  = 5                       
//   special = false
//   upper   = false
//   lower   = true
//   number  = true
// }
#checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
module "rg" {
  source                  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name     = var.resource_group_name
  location                = var.location
  tags                    = var.tags
}
#checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
module "servicebus" {
  depends_on = [module.rg]
  source                        = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-service-bus?ref=v1.0.0"
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
#checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
module "user_assigned_identity" {
  depends_on = [module.rg]
  source                      = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-user-assigned-identity?ref=v1.0.0"
  resource_group_name         = module.rg.resource_group_name
  location                    = var.location
  user_assigned_identity_name = var.mgid
  tags                        = var.tags
}
#checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
module "role_assignments" {
  depends_on = [module.servicebus, module.user_assigned_identity]
  source = "../../"
  // source = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-role-assignment"
  
  // user_assigned_managed_identities_by_display_name = {
  //   mi1 =  var.mgid # Note we are using the same key as the system assigned managed identity, this principal will get precedence over the system assigned managed identity. The system assigned managed identity will be ignored.
  // }
  
  user_assigned_managed_identities_by_principal_id = {
    mi1 =  module.user_assigned_identity.mi_principal_id
  }
  role_definitions = {
    role1 = var.role
  }
  role_assignments_for_resources = {
    example1 = {
      resource_name       = var.servicebus_name
      resource_group_name = var.resource_group_name
      role_assignments = {
        role_assignment_1 = {
          role_definition                  = "role1"
          // any_principals                = ["mi1"]
          user_assigned_managed_identities = ["mi1"]
        }
      }
    }
  }
}