terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# resource "azurerm_resource_group" "gitlab_rg" {
#   count    = var.create_rg ? 1 : 0

#   name     = var.resource_group_name
#   location = var.location
# }

# module "glee-download" {
#   source = "./module/gitlab-ee-downloader"

#   resource_group_name = azurerm_resource_group.gitlab_rg.name
#   create_rg           = false
#   location            = azurerm_resource_group.gitlab_rg.location
# }

data "azurerm_storage_blob" "girlab_blob" {
  name                   = "gitlab-ee*.deb"
  storage_account_name   = "lab1sty95w6d"
  storage_container_name = "gitlabfiles"
}