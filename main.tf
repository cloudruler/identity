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
  enable_rbac_authorization       = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_ssh_public_key" "ssh_cloudruler_public" {
  name                = "ssh-cloudruler"
  resource_group_name = upper(azurerm_resource_group.rg.name)
  location            = var.location
  public_key          = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7cOgQda7eyDAWQNPO8vkiaMAFczP8a+Qzkd+RDS75CA7qBGPzi89PPtWkp7U6eXrnIBwuxoud4M8Fr8ikfNhcU5F9MSE64H8sl4NGwMRVkwOp/2hE+23rO/ahLlo5F0O32TByH8wkyuHD3rbKZJS+FtrF0wdlnFb7yuxK18XLCy8Q9Tlc3Mpaeuo46uPvJ1NsBDyATfSzsKQ4fFnFQgD/UMm6S2hduvM0ETJWzDGKQMacMbN/I+DzGKcMgkN09jJjTZuUTBgq032AStfSeLv0CZhoqulmRck+Kj/UMysYPvIEjqiRqQumAKoQHo+7DtNVpRB/2geg+kEuesFhJi1wjSjp++59hHCSjVcwHXbTbdxytwHh1ErTJ/F2uUCHXfQFtNylGPe7qjBG87fNmVkykBgTzprF2UFSdmqkoSnn81h6WBT0Mflskdoo1mQW2HG0HP82nj+dCREz2qCc2mAQeyi9k0JvJJFR/VhXNmPhgftqX9xdBtlQ39zCnkZAlpBJUsjhwD8X7Y25p+Fyu+vNmz3+/qf3TS8NhnT+rE8SJZcfA3ngxf5dSR35IQNw05WN9zogEGpndMTWFgjwODfX8uYHSSwsiw4FFMFI0UAXWbnr/prJ3xwiN8CvEhYwo0rpr3wz7HEzi3LWSgjc4/1j79/Y9HX1ttWR2Gea9s52hw==
    EOT
}

resource "azurerm_ssh_public_key" "ssh_brianmoore" {
  name                = "ssh-brianmoore"
  resource_group_name = upper(azurerm_resource_group.rg.name)
  location            = var.location
  public_key          = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+HxnuN1D7vtkxABtAxRizT2RrUha45M3qBABWKBJAEJqev9gUC0zRxAwW6Eh8lhfv9jKcnekMkOZNPrR/Bx5cuv0hACDxF4nb2trcFTK2IOuaGidk3zld71jQYDnpVes9BSqcMkn9nmx8Nl7p5KPt1foTSezdZq/neiOZ/vV5r8iPmSOwxigYFP2G70P2dMFTY+KyoWDk60WAjr2g6EHSdI4GgR6kghgMAcVuljnseDJVLmYn8I/B2FSXH7APtd0h6J673S8wPZuNzIEYzm/KEobBn0EpnhyqfOjN5VLdNOUGpXb/VPNXeKaB3KoOzEh20FkaVJmNXlN0WKC1hyCl brian@DESKTOP-SFIVOEU
    EOT
}

resource "azurerm_app_configuration" "appcs" {
  count               = 0
  name                = "appcs-cloudruler"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "free"
}

resource "azurerm_storage_account" "st" {
  name                      = "cloudruler"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
  tags                      = {
    "ms-resource-usage"     = "azure-cloud-shell"
  }
  lifecycle {
    prevent_destroy = true
  }
}
