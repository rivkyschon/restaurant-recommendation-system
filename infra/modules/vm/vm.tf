terraform {
  required_providers {
    azurerm = {
      version = "~>3.97.1"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.24"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy Network Security Group
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "nsg_name" {
  name          = "${var.resource_token}-nsg"
  resource_type = "azurerm_network_security_group"
  random_length = 0
  clean_input   = true
}

resource "azurerm_network_security_group" "nsg" {
  name                = azurecaf_name.nsg_name.result
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Allow from any source
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy Network Interface
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "nic_name" {
  name          = "${var.resource_token}-nic"
  resource_type = "azurerm_network_interface"
  random_length = 0
  clean_input   = true
}

resource "azurerm_network_interface" "nic" {
  name                = azurecaf_name.nic_name.result
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# ------------------------------------------------------------------------------------------------------
# Associate NSG with NIC
# ------------------------------------------------------------------------------------------------------
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Linux Virtual Machine
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "vm_name" {
  name          = "${var.resource_token}-vm"
  resource_type = "azurerm_linux_virtual_machine"
  random_length = 0
  clean_input   = true
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = azurecaf_name.vm_name.result
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "osDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  custom_data = filebase64("${path.module}/install-docker.sh")
}
