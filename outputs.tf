output "keyvault_id" {
  value = azurerm_key_vault.kv.id
}

output "keyvault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}
