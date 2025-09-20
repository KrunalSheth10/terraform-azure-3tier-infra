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
# storage account
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

# Storage container
resource "azurerm_storage_container" "container"{
  name = "krunal-storage-container"
  storage_account_name = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name = "krunal-vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.0.0.0/16"]
}

# Web Subnet
resource "azurerm_subnet" "web"{
  name = "web-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

# App Subnet 
resource "azurerm_subnet" "app"{
  name = "app-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes =["10.0.2.0/24"]
}

# DataBase Subnet
resource "azurerm_subnet" "db" {
  name = "db-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.3.0/24"]
}

