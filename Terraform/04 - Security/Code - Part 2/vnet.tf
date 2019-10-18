resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = var.location
  resource_group_name = var.rg
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "10.0.1.0/24"
  }