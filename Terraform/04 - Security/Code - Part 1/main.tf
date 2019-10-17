data "azurerm_resource_group" "lab04" {
  name = var.rg
}

#data "azurerm_client_config" "current" {}

data "azuread_user" "lab04-user" {
  user_principal_name = var.labUser
}

data "azurerm_key_vault" "lab04" {
  name                = "mykeyvault"
  resource_group_name = azurerm_resource_group.lab04.name
}

resource "random_password" "admin_pwd" {
  length = 24
  special = true
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.lab04.id

  tenant_id = azurerm_client_config.current.tenant_id
  object_id = azurerm_client_config.current.object_id

  secret_permissions = [
    "list", "get", "delete", "set"
  ]
}

resource "azurerm_key_vault_secret" "lab04" {
  name         = "lab04_admin"
  value        = random_password.admin_pwd
  key_vault_id = azurerm_key_vault.test.id
}