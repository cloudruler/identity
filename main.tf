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
  name     = "rg-identity-scu"
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                            = "cloudrulerkvidentity"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true

  access_policy {
    #Access policy for Terraform Service Principal
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
resource "tls_private_key" "k8s_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "k8s_ssh_key_public_openssh" {
  name         = "k8s-ssh-key-public-openssh"
  value        = tls_private_key.k8s_ssh_key.public_key_openssh
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "k8s_ssh_key_public_pem" {
  name         = "k8s-ssh-key-public-pem"
  value        = tls_private_key.k8s_ssh_key.public_key_pem
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "k8s_ssh_key_private_pem" {
  name         = "k8s-ssh-key-private-pem"
  value        = tls_private_key.k8s_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]
  }
}

