# Configure Vnet and Default Subnet
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "10.0.1.0/24"
  }
}