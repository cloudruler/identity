provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# data "azuread_service_principal" "keyvault_admin_spn" {
#   display_name = var.keyvault_admin_spn
# }

data "azuread_users" "keyvault_admin_users" {
  user_principal_names = var.keyvault_admin_users
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-identity"
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                            = "cloudruler"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true

  access_policy {
    #Access policy for Azure Infrastructure Automation Service Principal
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    certificate_permissions = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers",
      "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
    ]
    key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover",
      "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"
    ]
    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS",
      "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }

  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = data.azuread_service_principal.keyvault_admin_spn.id
  #   certificate_permissions = [
  #     "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers",
  #     "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  #   ]
  #   key_permissions = [
  #     "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover",
  #     "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"
  #   ]

  #   secret_permissions = [
  #     "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  #   ]

  #   storage_permissions = [
  #     "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS",
  #     "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  #   ]
  # }

  dynamic "access_policy" {
    for_each = data.azuread_users.keyvault_admin_users.users
    iterator = user
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = user.value["object_id"]
      certificate_permissions = [
        "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers",
        "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
      ]
      key_permissions = [
        "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover",
        "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"
      ]

      secret_permissions = [
        "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
      ]

      storage_permissions = [
        "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS",
        "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
      ]
    }
  }
}

#SSH Key
resource "tls_private_key" "ssh_key_cloudruler" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_key_cloudruler_private_pem" {
  name         = "ssh-key-cloudruler-private-pem"
  value        = tls_private_key.ssh_key_cloudruler.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_ssh_public_key" "ssh_cloudruler_public" {
  name                = "ssh-cloudruler"
  resource_group_name = UPPER(azurerm_resource_group.rg.name)
  location            = var.location
  public_key          = tls_private_key.ssh_key_cloudruler.public_key_openssh
}

resource "azurerm_app_configuration" "appcs" {
  name                     = "appcs-cloudruler"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  sku                      = "free"
}
