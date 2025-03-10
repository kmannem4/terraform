provider "azurerm" {
  features {}
  subscription_id = "9b1a0b70-5da9-4188-bf75-b5d12bb8ca24"
}

run user_assigned_identity_output_tests {
    command = apply

    assert {
        condition     = module.user_assigned_identity.mi_id != ""
        error_message = "ID of the User Assigned Identity must not be null"
    }

    assert {
        condition     = module.user_assigned_identity.mi_principal_id != ""
        error_message = "ID of the app associated with the Identity must not be null"
    }

    assert {
        condition     = module.user_assigned_identity.mi_client_id != ""
        error_message = "ID of the Service Principal object associated with the created Identity must not be null"
    }

    assert {
        condition     = module.user_assigned_identity.mi_tenant_id != ""
        error_message = "ID of the Tenant which the Identity belongs to must not be null"
    }

    assert {
        condition     = module.user_assigned_identity.mi_tenant_name == local.user_assigned_identity_name
        error_message = "Name of the User Assigned Identity must not be null"
    }

    assert {
        condition     = module.user_assigned_identity.mi_tenant_location == var.location
        error_message = "Location of the User Assigned Identity must not be null"
    }

    assert {
        condition     = module.user_assigned_identity.mi_tenant_resource_group_name == local.resource_group_name
        error_message = "Resource Group of the User Assigned Identity must not be null"
    }

}