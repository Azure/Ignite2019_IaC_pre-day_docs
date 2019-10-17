data "azurerm_resource_group" "lab04" {
  name = var.rg
}

data "azurerm_key_vault" "lab04" {
  name                = "mykeyvault"
  resource_group_name = azurerm_resource_group.lab04.name
}

data "azurerm_key_vault_secret" "lab04" {
  name         = var.secretId
  key_vault_id = data.azurerm_key_vault.existing.id
}

# azurerm_key_vault_secret.lab04.value