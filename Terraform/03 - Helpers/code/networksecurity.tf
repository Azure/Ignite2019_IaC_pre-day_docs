resource "azurerm_network_security_rule" "custom_rules" {
  count                       = length(var.custom_rules)
  name                        = lookup(var.custom_rules[count.index], "name", "default_rule_name")
  priority                    = lookup(var.custom_rules[count.index], "priority")
  direction                   = lookup(var.custom_rules[count.index], "direction", "Any")
  access                      = lookup(var.custom_rules[count.index], "access", "Allow")
  protocol                    = lookup(var.custom_rules[count.index], "protocol", "*")
  source_port_ranges          = lookup(var.custom_rules[count.index], "source_port_range", "0-65535" )
  destination_port_ranges     = lookup(var.custom_rules[count.index], "destination_port_range", "0-65535")
  source_address_prefix       = lookup(var.custom_rules[count.index], "source_address_prefix", "*")
  destination_address_prefix  = lookup(var.custom_rules[count.index], "destination_address_prefix", "*")
  description                 = lookup(var.custom_rules[count.index], "description", "Security rule")
  resource_group_name         = azurerm_resource_group.nsg.name
  network_security_group_name = azurerm_network_security_group.nsgsecureweb.name
}