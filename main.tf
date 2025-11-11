# ========================================================
# Terraform INIT
# ========================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
    subscription_id = var.subscription_id
}

# Get information about the current Azure client (your logged-in user or service principal)
data "azurerm_client_config" "current" {}


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
  storage_account_id        = azurerm_storage_account.storage.id
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
# Public IP for Web Virtual Machine (VM) 
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
# Linux Virtual Machine For Web
# ========================================================

/*resource "azurerm_linux_virtual_machine" "web_vm" {
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
  }
}*/


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
}

# Associate NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
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
}

# ========================================================
# App Virtual Machine (VM)
# ========================================================

resource "azurerm_linux_virtual_machine" "app_vm" {
  name                          = "app-vm"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  size                          = "Standard_B1s"
  admin_username                = "azureuser"
  network_interface_ids         = [azurerm_network_interface.app-nic.id]
  os_disk {
    name                        = "app-os-disk"
    caching                     = "ReadWrite"
    storage_account_type        = "Standard_LRS" 
  }  

  source_image_reference {
    publisher                   = "Canonical"
    offer                       = "0001-com-ubuntu-server-focal"
    sku                         = "20_04-lts-gen2"
    version                     = "latest"  
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:\\Users\\DELL\\.ssh\\id_rsa.pub")
  }

  identity {
    type = "SystemAssigned"
  }

  disable_password_authentication = true
      
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
# Network Interface (NIC) for DataBase VM
# ========================================================

resource "azurerm_network_interface" "db_nic" {
  name                        =  "db-nic"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name 

  ip_configuration {
    name                      = "db-ip-config"
    subnet_id                 = azurerm_subnet.db.id
    private_ip_address_allocation =  "Dynamic"
  } 
}


# ========================================================
# Database virtual Machine  (VM)
# ========================================================

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                          = "db-vm"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  size                          = "Standard_B1s"
  admin_username                = "azureuser"
  network_interface_ids         = [azurerm_network_interface.db_nic.id]
  
  os_disk {
    name                        = "db-os-disk"
    caching                     = "ReadWrite"
    storage_account_type        = "Standard_LRS" 
  }  

  source_image_reference {
    publisher                   = "Canonical"
    offer                       = "0001-com-ubuntu-server-focal"
    sku                         = "20_04-lts-gen2"
    version                     = "latest"  
  }

  admin_ssh_key {
    username                    = "azureuser"
    public_key                  = file("C:\\Users\\DELL\\.ssh\\id_rsa.pub")
  }

  disable_password_authentication = true 
}

# ========================================================
# Public IP for load balancer
# ========================================================

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ========================================================
# Load Balancer for Web Tier
# ========================================================

resource "azurerm_lb" "web_lb" {
  name                = "web-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "web_backend_pool" {
  name                = "web-backend-pool"
  loadbalancer_id     = azurerm_lb.web_lb.id
}

# Health Probe
resource "azurerm_lb_probe" "web_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.web_lb.id
  protocol            = "Tcp"
  port                = 80
}

# Load Balancing Rule
resource "azurerm_lb_rule" "web_lb_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.web_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_backend_pool.id]
  probe_id                       = azurerm_lb_probe.web_probe.id
}

# Associate Web VM NIC with Backend Pool
/*resource "azurerm_network_interface_backend_address_pool_association" "web_nic_lb_association" {
  network_interface_id    = azurerm_network_interface.web_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_backend_pool.id
}*/

# ========================================================
# Web Virtual Machine Scale Set (VMSS) Instad of Web VM
# ========================================================

resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name = "web-vmss"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard_B1ms"
  instances = 2
  admin_username = "azureuser"

  admin_ssh_key {
    username = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  upgrade_mode = "Automatic"

  network_interface {
    name = "webvmss-nic"
    primary = true
    ip_configuration {
      name = "webvmss-ipconfig"
      subnet_id = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_backend_pool.id]
      primary = true
    }
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  computer_name_prefix = "webvm"

  tags = {
    environment = "dev"
    Tier = "web"
  }
}

# ========================================================
# KEY VAULT
# ========================================================

resource "azurerm_key_vault" "kv" {
  name = "kv-${var.project_name}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  #soft_delete_enabled = true
  purge_protection_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }

  tags = {
    environment = var.environment
    project = var.project_name
  }
}

resource "azurerm_key_vault_access_policy" "vmss_kv_access" /*For Web VM*/{
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_linux_virtual_machine_scale_set.web_vmss.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "appvm_kv_access" /*For App VM*/{
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_linux_virtual_machine.app_vm.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

# ========================================================
# Store Secrets
# ========================================================

resource "azurerm_key_vault_secret" "db_password" {
  name = "db-password"
  value = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_connection" {
  name         = "db-connection-string"
  value        = "Server=${azurerm_linux_virtual_machine.db_vm.private_ip_address};Database=mydb;User Id=adminuser;Password=${var.db_password};"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = "db-admin-password"
  value        = var.db_admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

# ========================================================
# PostgreSQL Database
# ========================================================

# PostgreSQL Flexible Server

resource "azurerm_postgresql_flexible_server" "db_server" {
  name = "${var.project_name}-db"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  administrator_login = "dbadmin"
  administrator_password = azurerm_key_vault_secret.db_admin_password.value
  version = "16"
  storage_mb = 32768
  sku_name = "B_Standard_B1ms"
  backup_retention_days = 7
  delegated_subnet_id    = azurerm_subnet.db.id
  private_dns_zone_id    = null

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }
}

# PostgreSQL Database

resource "azurerm_postgresql_flexible_server_database" "app_db" {
  name = "${var.project_name}-appdb"
  server_id = azurerm_postgresql_flexible_server.db_server.id
  collation = "en_US.utf8"
  charset = "UTF8" 
}
