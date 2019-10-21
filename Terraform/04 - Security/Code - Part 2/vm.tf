# Data source reference to key vault instance
data "azurerm_key_vault" "tf_pre-day" {
  name                = var.keyVault
  resource_group_name = var.rg
}

# Data source reference to the secret
data "azurerm_key_vault_secret" "tf_pre-day" {
  name         = var.secretId
  key_vault_id = data.azurerm_key_vault.tf_pre-day.id
}

# Configure Virtual Machine
resource "azurerm_virtual_machine" "predayvm" {
  name                  = "tfignitepredayvm"
  location              = var.location
  resource_group_name   = var.rg
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.predaynic.id]

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
    admin_password = data.azurerm_key_vault_secret.tf_pre-day.value
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags                = var.tags
}

