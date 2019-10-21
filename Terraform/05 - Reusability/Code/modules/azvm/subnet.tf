# Configure Subnet
resource "azurerm_subnet" "predaysubnet" {
  name                 = "default"
  resource_group_name  = var.rg
  virtual_network_name = var.vnet_name
  address_prefix       = var.subnet_cidr # Change to variable for module reuse
}

resource "azurerm_network_security_group" "predaysg" {
  name                = "default-rules-${var.host_name}"
  location            = var.location
  resource_group_name = var.rg

  dynamic "security_rule" {
    for_each = var.securityGroupRules

    content {
      name                       = lower(security_rule.value.name)
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = title(security_rule.value.protocol)
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destinationPortRange
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "preday" {
  subnet_id                 = azurerm_subnet.predaysubnet.id
  network_security_group_id = azurerm_network_security_group.predaysg.id
}
