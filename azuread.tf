data "azuread_users" "users" {
  user_principal_names = ["brianmoore@cloudruler.com"]
}

resource "azuread_application" "vault_automation" {
  display_name    = "vault-automation"
  owners          = data.azuread_users.users.object_ids
  identifier_uris = ["https://infrastructureautomation.cloudruler.com"]

  required_resource_access {
    #Microsoft Graph
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "741f803b-c850-494e-b5df-cde7c675a1ca"
      type = "Role"
    }
    resource_access {
      id   = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9"
      type = "Role"
    }
    resource_access {
      id   = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
      type = "Role"
    }
  }

  web {
    homepage_url  = "https://vaultautomation.cloudruler.com/"
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "vault_automation" {
  application_id               = azuread_application.vault_automation.application_id
  app_role_assignment_required = false
  owners                       = data.azuread_users.users.object_ids
}