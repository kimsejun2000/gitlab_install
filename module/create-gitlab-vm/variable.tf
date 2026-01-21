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

variable "virtual_network" {
  type        = object({
    name                  = string,
    resource_group_name   = string
  })
  description = "The name of the virtual network"
}

variable "subnet" {
  type        = object({
    name      = string
  })
  description = "The name of the subnet"
}

variable "network_security_group" {
  type        = object({
    id        = string
  })
  description = "The name of the network security group"
}

variable "storage_account" {
  type        = object({
    name      = string,
    id        = string
  })
  description = "The name of the storage account"
}

variable "storage_container" {
  type        = object({
    name      = string,
    id        = string
  })
  description = "The name of the container on the storage account"
}