variable "resource_group" {
  type        = object({
    name = string,
    location = string
  })
  description = "The name of the resource group"
}

variable "name" {
  type        = string
  description = "The name prefix for resources"
  default     = "gitlab"
}

variable "create_vnet" {
  type        = bool
  description = "Whether to create a virtual network"
  default     = true
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
