terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.49"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.17.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-identity"
    storage_account_name = "cloudruler"
    container_name       = "tfstates"
    key                  = "identity.tfstate"
  }
  required_version = ">= 0.14.7"
}