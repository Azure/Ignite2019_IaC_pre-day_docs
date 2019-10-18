# Data source reference to key vault instance
data "azurerm_key_vault" "lab04" {
  name                = var.keyVault
  resource_group_name = azurerm_resource_group.lab04.name
}

# Data source reference to the secret
data "azurerm_key_vault_secret" "lab04" {
  name         = var.secretId
  key_vault_id = data.azurerm_key_vault.existing.id
}

# Configure Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                  = "tfignitepredayvm"
  location              = var.location
  resource_group_name   = var.rg
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = azurerm_key_vault_secret.lab04.value
  }
}