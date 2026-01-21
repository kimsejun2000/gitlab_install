output "storage_account" {
  value = azurerm_storage_account.gitlab_storage
}

output "storage_container" {
  value = azurerm_storage_container.gitlab_blob
}
