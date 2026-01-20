output "storage_account_name" {
  value = azurerm_storage_account.gitlab_storage.name
}

output "storage_container_name" {
  value = azurerm_storage_container.gitlab_blob.name
}

data "azurerm_storage_blob" "girlab_blob" {
  name                   = "gitlab-ee*"
  storage_account_name   = azurerm_storage_account.gitlab_storage.name
  storage_container_name = azurerm_storage_container.gitlab_blob.name
}

output "storage_container_blob" {
  value = data.azurerm_storage_blob.girlab_blob.name
}