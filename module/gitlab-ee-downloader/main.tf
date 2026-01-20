terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "tail_string" {
  length  = 6
  upper   = false
  special = false
}

locals {
  storage_account_name = lower(substr("${var.storage_account_name}${random_string.tail_string.result}", 0, 24))
}

resource "azurerm_resource_group" "gitlab_rg" {
  count    = var.create_rg ? 1 : 0

  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "gitlab_storage" {
  name                     = local.storage_account_name
  resource_group_name      = var.create_rg ? azurerm_resource_group.gitlab_rg.name : var.resource_group_name
  location                 = var.create_rg ? azurerm_resource_group.gitlab_rg.location : var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "gitlab_blob" {
  name                  = "gitlabfiles"
  storage_account_id    = azurerm_storage_account.gitlab_storage.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "gitlab_script" {
  name                   = "script.sh"
  storage_account_name   = azurerm_storage_account.gitlab_storage.name
  storage_container_name = azurerm_storage_container.gitlab_blob.name
  type                   = "Block"
  source                 = "./upload_gitlab_dap.sh"
}

data "azurerm_storage_account_blob_container_sas" "gitlab_script_sas" {
  connection_string      = azurerm_storage_account.gitlab_storage.primary_connection_string
  container_name         = azurerm_storage_container.gitlab_blob.name
  start                  = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
  expiry                 = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timeadd(timestamp(), "5m"))
  
  permissions {
    read   = true
    write  = false
    delete = false
    list   = false
    add    = false
    create = false
  }
}

resource "azurerm_container_group" "gitlab_aci" {
  name                = "gitlab-aci"
  location            = var.create_rg ? azurerm_resource_group.gitlab_rg.location : var.location
  resource_group_name = var.create_rg ? azurerm_resource_group.gitlab_rg.name : var.resource_group_name
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "gitlab-downloader"
    image  = "kimsejun54/azure-cli:ubuntu"
    cpu    = "0.5"
    memory = "1"
    commands = [ "/bin/bash", 
      "-c", 
      "curl '${azurerm_storage_blob.gitlab_script.url}${data.azurerm_storage_account_blob_container_sas.gitlab_script_sas.sas}' -o script.sh&&chmod +x ./script.sh&&./script.sh" 
    ]
    environment_variables = { 
      "ST_NAME" = azurerm_storage_account.gitlab_storage.name
      "ST_CONTAINER" = azurerm_storage_container.gitlab_blob.name
      "ST_KEY" = azurerm_storage_account.gitlab_storage.primary_access_key
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "gitlab-${random_string.tail_string.result}"
}
