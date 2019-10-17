data "azurerm_resource_group" "lab04" {
  name = "dsrg_test"
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
  key_vault_id = "${azurerm_key_vault.test.id}"

  tenant_id = "00000000-0000-0000-0000-000000000000"
  object_id = "11111111-1111-1111-1111-111111111111"

  secret_permissions = [
    "get",
  ]
}

resource "azurerm_key_vault_secret" "lab04" {
  name         = "secret-sauce"
  value        = random_password.admin_pwd
  key_vault_id = azurerm_key_vault.test.id
}