terraform {
  required_providers {
    azurerm   = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "krunal-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage"{
  name                      = "krunalstorageacct" # must be globally unique, lowercase only
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "container"{
  name = "krunal-storage-container"
  storage_account_name = azurerm_storage_account.storage.name
  container_access_type = "private"
}