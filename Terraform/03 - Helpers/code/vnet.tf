# Configure Vnet -- pull subnet out to its own resource to demonstrate references / dependencies
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = var.location
  resource_group_name = var.rg
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Configure Subnet
resource "azurerm_subnet" "predaysubnet" {
  name                 = "subnet1"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.predayvnet.name
  address_prefix       = "10.0.1.0/24"
}

# Web subnet
resource "azurerm_subnet" "predaywebsubnet" {
  name                 = "web"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.predayvnet.name
  address_prefix       = "10.0.2.0/24"
  network_security_group_id = azurerm_network_security_group.predaysg.id  
}

resource "azurerm_network_security_group" "predaysg" {
  name                = "web-rules"
  location            = var.location
  resource_group_name = var.rg

  dynamic "security_rule" {
    for_each = var.security_group_rules

    content {
      name                       = lower(security_rule.value.name)
      priority                   = security_rule.value.priority
      direction                  = title(security_rule.value.direction)
      access                     = title(security_rule.value.access)
      protocol                   = title(security_rule.value.protocol)
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destinationPortRange
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "preday" {
  subnet_id                 = azurerm_subnet.predaywebsubnet.id
  network_security_group_id = azurerm_network_security_group.predaysg.id
}
