# resource "azurerm_role_assignment" "example" {
#   scope                = data.azurerm_subscription.primary.id
#   role_definition_name = "Reader"
#   principal_id         = data.azurerm_client_config.example.object_id
# }

# resource "azurerm_role_assignment" "example" {
#   name               = "00000000-0000-0000-0000-000000000000"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.example.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.example.object_id
# }