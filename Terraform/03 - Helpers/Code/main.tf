locals {
  base_cidr_block = "10.0.0.0/16"
  subnets = [
    {
      name   = "a"
      number = 1
    },
    {
      name   = "b"
      number = 2
    },
    {
      name   = "c"
      number = 3
    },
  ]
  rules = [
      {
          name = "DNS"
          source_addresses = ["10.0.0.0/16"]
          destination_ports = ["53"]
          destination_addresses = ["8.8.8.8","8.8.4.4"]
          protocols = ["TCP","UDP"]
      },
      {
          name = "HTTPS"
          source_addresses = ["10.0.0.0/16"]
          destination_ports = ["443"]
          destination_addresses = ["1.1.1.1","2.2.2.2"]
          protocols = ["TCP"]
      }
  ]
}

resource "azurerm_resource_group" "test" {
    name        = "mine_not_yours"
    location    = "general"
  
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = [local.base_cidr_block]
  location            = azurerm_resource_group.test.name

  dynamic "subnet" {
    for_each = [for s in local.subnets: {
      name   = s.name
      prefix = cidrsubnet(local.base_cidr_block, 4, s.number)
    }]

    content {
      name           = subnet.value.name
      address_prefix = subnet.value.prefix
    }
  }
}

resource "azurerm_public_ip" "test" {
  name                = "testfirewall"
  location            = azurerm_resource_group.test.name
  resource_group_name = azurerm_resource_group.test.name

  allocation_method   = "Static"
}


resource "azurerm_firewall" "test" {
  name                = "testfirewall"
  location            = azurerm_resource_group.test.name
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "alskdfjadslkfj"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_firewall_nat_rule_collection" "test" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.test.name
  resource_group_name = azurerm_resource_group.test.name
  priority            = 100
  action              = "Dnat"

  dynamic "rule" {
      for_each = local.rules

      content {
          name = rule.value.name
          source_addresses = rule.value.source_addresses
          destination_ports = rule.value.destination_ports
          destination_addresses = rule.value.destination_addresses
          protocols = rule.value.protocols
          translated_address = "10.0.10.10"
          translated_port = "8888"
      }
  }
}