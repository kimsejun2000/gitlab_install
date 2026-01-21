output "subnet" {
  value = var.create_vnet ? azurerm_subnet.main[0] : null
}

output "virtual_network" {
  value = var.create_vnet ? azurerm_virtual_network.main[0] : null
}

output "network_security_group" {
  value = azurerm_network_security_group.main
}