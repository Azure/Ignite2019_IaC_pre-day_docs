output "vm_id" {
  value = azurerm_virtual_machine.predayvm.id
}

output "vm_msi" {
  value = azurerm_virtual_machine.predayvm.identity[0].principal_id
}

output "mac_address" {
  value = azurerm_network_interface.predaynic.mac_address
}

output "private_ip" {
  value = azurerm_network_interface.predaynic.private_ip_address
}
