terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  resource_tags = {
    Name = var.name
  }
}

resource "azurerm_virtual_network" "main" {
  count               = var.create_vnet ? 1 : 0

  name                = "${var.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet" "main" {
  count                = var.create_vnet ? 1 : 0

  name                 = "${var.name}-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.name}-nsg"
  location            = var.create_vnet ? var.resource_group.location : var.virtual_network_name
  resource_group_name = var.resource_group.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
