provider "time" {
}

locals {
  admin_upns = ["brianmoore@cloudruler.com"]
}

data "azuread_users" "admin_users" {
  user_principal_names = local.admin_upns
}

resource "azuread_application" "vault_automation" {
  display_name    = "vault-automation"
  owners          = data.azuread_users.admin_users.object_ids
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
  owners                       = data.azuread_users.admin_users.object_ids
}

resource "time_rotating" "vault_automation" {
  rotation_years = 2
}

resource "azuread_service_principal_password" "vault_automation" {
  display_name = "1"
  service_principal_id = azuread_service_principal.vault_automation.object_id
  rotate_when_changed = {
    rotation = time_rotating.vault_automation.id
  }
}

data "azurerm_subscription" "current" {
}

resource "azurerm_role_assignment" "vault_administrator_contributor" {
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id       = azuread_service_principal.vault_automation.object_id
}

resource "azurerm_role_assignment" "vault_administrator_user_access_admin" {
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "User Access Administrator"
  principal_id       = azuread_service_principal.vault_automation.object_id
}

resource "azurerm_role_assignment" "vault_administrator_key_vault_admin" {
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Administrator"
  principal_id       = azuread_service_principal.vault_automation.object_id
}

resource "azurerm_role_assignment" "admin_user_key_vault_admin" {
  for_each = { for user in data.azuread_users.admin_users.users : user.user_principal_name => user }
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Administrator"
  principal_id       = each.value.object_id
}

resource "azurerm_key_vault_secret" "vault_administrator_secret" {
  name         = "vault-automation-secret"
  value        = azuread_service_principal_password.vault_automation.value
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "Password for the vault-automation SPN"
}
