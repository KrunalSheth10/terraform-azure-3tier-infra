# ========================================================
# Terraform INIT
# ========================================================

terraform {
  required_providers {
    azurerm                   = {
      source                  = "hashicorp/azurerm"
      version                 = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# ========================================================
# Resource Group
# ========================================================
resource "azurerm_resource_group" "rg" {
  name                        = "krunal-rg"
  location                    = "East US"
}

# ========================================================
# storage account
# ========================================================

resource "azurerm_storage_account" "storage"{
  name                        = "krunalstorageacct" # must be globally unique, lowercase only
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  
  tags                        = {
    environment               = "dev"
  }
}

# ========================================================
# Storage container
# ========================================================

resource "azurerm_storage_container" "container"{
  name                        = "krunal-storage-container"
  storage_account_name        = azurerm_storage_account.storage.name
  container_access_type       = "private"
}

# ========================================================
# Virtual Network
# ========================================================

resource "azurerm_virtual_network" "vnet" {
  name                        = "krunal-vnet"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  address_space               = ["10.0.0.0/16"]
}

# ========================================================
# Web Subnet
# ========================================================

resource "azurerm_subnet" "web"{
  name = "web-subnet"
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_network_name        = azurerm_virtual_network.vnet.name
  address_prefixes            = ["10.0.1.0/24"]
}

# ========================================================
# NSG for Web Subnet
# ========================================================

resource "azurerm_network_security_group" "web_nsg" {
  name                        = "web-nsg"
  location                    = azurerm_resource_group.rg.location 
  resource_group_name         = azurerm_resource_group.rg.name
}

# Allow HTTP for Web Subnet
resource "azurerm_network_security_rule" "web_http" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web_nsg.name 
}

# Allow HTTPS
resource "azurerm_network_security_rule" "web_https" {
  name                        = "Allow-HTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web_nsg.name
}

#Allow SSh (for admin access) Web Subnet
resource "azurerm_network_security_rule" "web_ssh" {
  name                        ="Allow-ssh"
  priority                    =120
  direction                   ="Inbound"
  access                      ="Allow"
  protocol                    ="Tcp"
  source_port_range           ="*"
  destination_port_range      ="22"
  source_address_prefix       ="*"
  destination_address_prefix  ="*"
  resource_group_name         =azurerm_resource_group.rg.name
  network_security_group_name =azurerm_network_security_group.web_nsg.name
}

# Associate NSG with Web Subnet
resource"azurerm_subnet_network_security_group_association" "web_assoc"{
  subnet_id                   = azurerm_subnet.web.id
  network_security_group_id   = azurerm_network_security_group.web_nsg.id
}

# ========================================================
# App Subnet 
# ========================================================

resource "azurerm_subnet" "app"{
  name                        = "app-subnet"
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_network_name        = azurerm_virtual_network.vnet.name
  address_prefixes            =["10.0.2.0/24"]
}

# ========================================================
# NSG for App Subnet
# ========================================================

resource "azurerm_network_security_group" "app_nsg"{
  name                        = "app_nsg"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
}

# Allow traffic only from Web Subnet

resource "azurerm_network_security_rule" "app_from_web"{
<<<<<<< HEAD
  name                          = "Allow-Web-To-App"
  priority                      = 100
  direction                     ="Inbound"
  access                        = "Allow"
  protocol                      = "*"
  source_port_range             = "*"
  destination_port_range        = "*"
  source_address_prefix         = azurerm_subnet.web.address_prefixes[0]
  destination_address_prefix    = "*"
  resource_group_name           =azurerm_resource_group.rg.name
  network_security_group_name   = azurerm_network_security_group.app_nsg.name
=======

name                          = "Allow-Web-To-App"
priority                      = 100
direction                     ="Inbound"
access                        = "Allow"
protocol                      = "*"
source_port_range             = "*"
destination_port_range        = "*"
source_address_prefix         = azurerm_subnet.web.address_prefixes[0]
destination_address_prefix    = "*"
resource_group_name           =azurerm_resource_group.rg.name
network_security_group_name   = azurerm_network_security_group.app_nsg.name
>>>>>>> origin/main
}

# Associate NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
<<<<<<< HEAD
  subnet_id                     = azurerm_subnet.app.id
  network_security_group_id     = azurerm_network_security_group.app_nsg.id
}

# ========================================================
# Network Interface (NIC) for App VM
# ========================================================

resource "azurerm_network_interface" "app-nic" {
  name                          = "app_nic"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name

  ip_configuration {
    name                        = "app-ip-config"
    subnet_id                   = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
=======
  subnet_id                   = azurerm_subnet.app.id
  network_security_group_id   = azurerm_network_security_group.app_nsg.id
>>>>>>> origin/main
}

# ========================================================
# DataBase Subnet
# ========================================================

resource "azurerm_subnet" "db" {
  name = "db-subnet"
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_network_name        = azurerm_virtual_network.vnet.name
  address_prefixes            = ["10.0.3.0/24"]
}

# ========================================================
# NSG for DataBase Subnet
# ========================================================

resource "azurerm_network_security_group" "db_nsg"{
  name                        = "db-nsg"
  location                    =  azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
}

# Allow traffic only App Subnet
resource "azurerm_network_security_rule" "db_from_app" {
  name                        = "Allow-App-To-DB"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.app.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.db.address_prefixes[0] 
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Associate NSG with DB Subnet
resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                   = azurerm_subnet.db.id
  network_security_group_id   = azurerm_network_security_group.db_nsg.id
}

# ========================================================
<<<<<<< HEAD
# Public IP for Web Virtual Machine (VM) 
=======
# Public IP for Web Virtual Machine (VM)
>>>>>>> origin/main
# ========================================================

resource "azurerm_public_ip" "web_ip" {
  name                        = "web-vm-ip"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  allocation_method           = "Static"
  sku                         = "Standard"
}
  
# ========================================================
# Network Interface (NIC) for Web VM
# ========================================================

resource "azurerm_network_interface" "web_nic" {
  name                        = "web-nic"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name

  ip_configuration {
    name                      = "web-ip-config"
    subnet_id                 = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id      = azurerm_public_ip.web_ip.id 
  }
}

# ========================================================
<<<<<<< HEAD
# Linux Virtual Machine For Web
# ========================================================

resource "azurerm_linux_virtual_machine" "web_vm" {
  name                        = "web-vm"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  network_interface_ids       = [azurerm_network_interface.web_nic.id]
  size                        = "Standard_B1s"
  admin_username              = "azureuser"

  admin_ssh_key {
    username                  = "azureuser"
    public_key                = file("C:/Users/DELL/.ssh/id_rsa.pub")
  }

  os_disk {
    name                      = "web-os-disk"
    caching                   = "ReadWrite"
    storage_account_type      = "Standard_LRS"
  }

  source_image_reference {
    publisher                 = "Canonical"
    offer                     = "0001-com-ubuntu-server-jammy"
    sku                       = "22_04-lts"
    version                   = "latest"
=======
# Linux Virtual Machine
# ========================================================

resource "azurerm_linux_virtual_machine" "web_vm" {
  name                = "web-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.web_nic.id]
  size                = "Standard_B1s"

  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/DELL/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
>>>>>>> origin/main
  }
}

