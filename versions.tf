terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.49"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = ">= 1.4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
  }
  backend "remote" {
    organization = "cloudruler"
    workspaces {
      name = "identity"
    }
  }
  required_version = ">= 0.14.7"
}