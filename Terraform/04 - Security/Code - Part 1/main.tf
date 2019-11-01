data "azurerm_resource_group" "lab04" {
  name = var.rg
}

data "azuread_user" "lab04-user" {
  user_principal_name = var.labUser
}

data "azurerm_key_vault" "lab04" {
  name                = var.key_vault
  resource_group_name = data.azurerm_resource_group.lab04.name
}

resource "random_password" "admin_pwd" {
  length = 24
  special = true
}

resource "azurerm_key_vault_access_policy" "lab04" {
  key_vault_id = data.azurerm_key_vault.lab04.id

  tenant_id = var.tenant_id
  object_id = data.azuread_user.lab04-user.id

  secret_permissions = [
    "list", "get", "delete", "set"
  ]
}

resource "azurerm_key_vault_secret" "lab04" {
  name         = var.secret_id
  value        = random_password.admin_pwd.result
  key_vault_id = data.azurerm_key_vault.lab04.id
}