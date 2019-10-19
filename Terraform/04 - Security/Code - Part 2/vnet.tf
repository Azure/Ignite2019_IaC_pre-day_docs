# Configure VNet and Subnet
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = var.location
  resource_group_name = var.rg
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Configure Subnet
resource "azurerm_subnet" "predaysubnet" {
  name                 = "default"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.predayvnet.name
  address_prefix       = "10.0.1.0/24"
}