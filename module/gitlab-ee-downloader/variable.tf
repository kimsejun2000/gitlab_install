variable "resource_group" {
  type        = object({
    name = string,
    location = string
  })
  description = "The name of the resource group"
}

variable "storage_account_name" {
  description = "The ID of the storage account"
  default     = "gitlabst"
}
