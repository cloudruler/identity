# Introduction 
This is the identity module. All enterprise secrets are stored here.


#State migration
If I ever need to migrate state, I'll need to import my resources using these commands:
terraform import azurerm_resource_group.rg /subscriptions/2fb80bcc-8430-4b66-868b-8253e48a8317/resourceGroups/rg-identity
terraform import azurerm_key_vault.kv /subscriptions/2fb80bcc-8430-4b66-868b-8253e48a8317/resourceGroups/rg-identity/providers/Microsoft.KeyVault/vaults/cloudruler
terraform import azurerm_storage_account.st /subscriptions/2fb80bcc-8430-4b66-868b-8253e48a8317/resourceGroups/rg-identity/providers/Microsoft.Storage/storageAccounts/cloudruler