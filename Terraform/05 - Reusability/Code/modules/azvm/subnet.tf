# Configure Subnet
resource "azurerm_subnet" "predaysubnet" {
  name                        = regex("^[[:alpha:]]+", var.host_name)
  resource_group_name         = var.rg
  virtual_network_name        = var.vnet_name
  address_prefix              = var.subnet_cidr # Change to variable for module reuse
  network_security_group_id   = azurerm_network_security_group.predaysg.id
}

resource "azurerm_network_security_group" "predaysg" {
  name                = "rules-${var.host_name}"
  location            = var.location
  resource_group_name = var.rg

  dynamic "security_rule" {
    for_each = var.security_group_rules

    content {
      name                       = lower(security_rule.value.name)
      description                = "Allow inbound traffic for ${security_rule.value.protocol}"
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
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