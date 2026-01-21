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

data "azurerm_subnet" "main" {
  name                 = var.subnet.name
  virtual_network_name = var.virtual_network.name
  resource_group_name  = var.virtual_network.resource_group_name
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.network_security_group.id
}

resource "azurerm_user_assigned_identity" "main" {
  location            = var.resource_group.location
  name                = "${var.name}-mi"
  resource_group_name = var.resource_group.name
}

resource "azurerm_role_assignment" "storage_reader" {
  scope                = var.storage_account.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.name}-vm"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  size                = "Standard_d4s_v5"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_password = "P@ssw0rd1234!" # For demo only; use SSH keys in production
  disable_password_authentication = false

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.name}-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null
    chmod go+r /etc/apt/keyrings/microsoft.gpg

    echo "Types: deb
    URIs: https://packages.microsoft.com/repos/azure-cli/
    Suites: $(lsb_release -cs)
    Components: main
    Architectures: $(dpkg --print-architecture)
    Signed-by: /etc/apt/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/azure-cli.sources

    apt update -y
    apt install -y azure-cli

    az login --identity --client-id ${azurerm_user_assigned_identity.main.client_id}

    mkdir /home/azureuser/gitlab_install
    cd /home/azureuser/gitlab_install
    az storage blob download-batch \
      --account-name ${var.storage_account.name} \
      --source ${var.storage_container.name} \
      --pattern gitlab-ee*.deb \
      --destination .

    dpkg -i $(ls /home/azureuser/gitlab_install/gitlab-ee*.deb)
  EOF
  )
}
