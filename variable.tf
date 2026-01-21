variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = "gitlab-rg"
}

variable "create_rg" {
  type        = bool
  description = "Set to true when you want to create a resource group."
  default     = false
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
  nullable    = true

  validation {
    condition = var.virtual_network_name == null && var.create_vnet == true
    error_message = "Virtual network name must be provided when create_vnet is false."
  }
}

variable "create_vnet" {
  type        = bool
  description = "Whether to create a virtual network"
  default     = true
}

variable "location" {
  type        = string
  default     = "koreacentral"
  description = "Azure region"
}

variable "storage_account_name" {
  description = "The ID of the storage account"
  default     = "gitlabst"
}

variable "subscription_id" {
  description = "The ID of the subscription"
}