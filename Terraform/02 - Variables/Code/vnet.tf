# Configure Vnet -- pull subnet out to its own resource to demonstrate references / dependencies
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = var.location
  resource_group_name = var.rg
  address_space       = ["10.0.0.0/16"]
}

# Configure Subnet
resource "azurerm_subnet" "predaysubnet" {
  name                 = "subnet1"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.predayvnet.name
  address_prefix       = "10.0.1.0/24"
}