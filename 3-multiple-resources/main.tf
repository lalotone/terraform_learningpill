terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# This is the name for the Terraform resource, NOT the Azure one.
# The Id for this resource in the Terraform config will be azurerm_resource_group.testrg
resource "azurerm_resource_group" "testrg" {
  # Attribute with the real name for the resource group
  name     = "testTF"
  location = "northeurope"
}

resource "azurerm_virtual_network" "vnet" {
    name                = "testTFVNET"
    # List with addresses
    address_space       = ["10.123.0.0/16"]
    location            = "northeurope"
    # Implicit dependency that will create the RG before the VNET
    # on the Terraform action plan
    resource_group_name = azurerm_resource_group.testrg.name
}

# Variable block. These variables will be prompted if are not configured
# on a variables file.
variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "testTFSubnet"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "testTFPubIP"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.testrg.name
  allocation_method   = "Static"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "testTFNSG"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.testrg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "testTFNIC"
  location                  = "northeurope"
  resource_group_name       = azurerm_resource_group.testrg.name

  ip_configuration {
    name                          = "TFNICConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "testTFVM"
  location              = "northeurope"
  resource_group_name   = azurerm_resource_group.testrg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "OS_DISK_TF"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Example of a dynamic var asignation. It will check the variable location, and after that, it will check
  # for a key on the 'sku' variable that contains the location used on the var.location
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = lookup(var.sku, var.location)
    version   = "latest"
  }

  os_profile {
    computer_name  = "testTFVM"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_virtual_machine.vm.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}
