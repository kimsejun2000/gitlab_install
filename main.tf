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

resource "azurerm_resource_group" "gitlab_rg" {
  count    = var.create_rg ? 1 : 0

  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "gitlab_rg" {
  count    = var.create_rg ? 0 : 1

  name     = var.resource_group_name
}

data "azurerm_virtual_network" "gitlab_vnet" {
  count               = var.create_vnet ? 0 : 1

  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

locals {
  gitlab_rg     = var.create_rg ? azurerm_resource_group.gitlab_rg[0] : data.azurerm_resource_group.gitlab_rg[0]
}

module "glee-download" {
  source = "./module/gitlab-ee-downloader"

  resource_group      = local.gitlab_rg
}

module "common" {
  source = "./module/common"

  resource_group       = local.gitlab_rg
  name                 = "gitlab"
  create_vnet          = var.create_vnet
  virtual_network_name = var.create_vnet ? null : var.virtual_network_name
}

resource "time_sleep" "wait_5_minutes" {
  depends_on = [module.glee-download]

  create_duration = "5m"
}

module "gitlab_vm" {
  source = "./module/create-gitlab-vm"

  resource_group      = local.gitlab_rg
  name                = "gitlab"
  virtual_network     = var.create_vnet ? module.common.virtual_network : data.azurerm_virtual_network.gitlab_vnet[0]
  subnet              = var.create_vnet ? module.common.subnet : data.azurerm_virtual_network.gitlab_vnet[0].subnets[0]
  network_security_group = module.common.network_security_group

  storage_account    = module.glee-download.storage_account
  storage_container  = module.glee-download.storage_container

  depends_on = [ module.common, time_sleep.wait_5_minutes ]
}