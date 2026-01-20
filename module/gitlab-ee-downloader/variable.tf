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

variable "location" {
  type        = string
  default     = "koreacentral"
  description = "Azure region"
}

variable "storage_account_name" {
  description = "The ID of the storage account"
  default     = "gitlabst"
}
