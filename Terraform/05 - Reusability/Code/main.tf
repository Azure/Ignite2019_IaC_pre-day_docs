locals {
    rg = "IoC-02-109843" ## Enter the resource group pre-created in your lab
    location = "West Europe" ## Enter the azure region for your resources if different from East US 2

    rg2 = "IoC-01-109843"
    key_vault = "keyvault109843"

    tags = {
        event           = "Ignite"
        year            = "2019"
        session_id      = "PRE04"
        iac_tool        = "terraform"
        lab             = "4"
    }

}

# Configure Vnet -- pull subnet out to its own resource to demonstrate references / dependencies
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = local.location
  resource_group_name = local.rg
  address_space       = ["172.16.0.0/16"]
  tags                = local.tags
}

module "frontend" {
  source              = "./modules/azvm"

  host_name           = "web001"
  rg                  = local.rg
  location            = local.location
  rg2                 = local.rg2
  secret_id           = "lab04admin"
  key_vault           = local.key_vault
  vnet_name           = azurerm_virtual_network.predayvnet.name
  subnet_cidr         = "172.16.10.0/24"
  security_group_rules = [
      {
          name                  = "http"
          priority              = 100
          protocol              = "tcp"
          destinationPortRange  = "80"
          direction             = "Inbound"
          access                = "Allow"
      },
      {
          name                  = "https"
          priority              = 150
          protocol              = "tcp"
          destinationPortRange  = "443"
          direction             = "Inbound"
          access                = "Allow"
      },
      {
          name                  = "deny-the-rest"
          priority              = 200
          protocol              = "*"
          destinationPortRange  = "0-65535"
          direction             = "Inbound"
          access                = "Deny"
      },
  ]

  tags                = local.tags
}

module "mysql_db" {
  source = "./modules/azvm"
  
  host_name           = "mysql001"
  rg                  = local.rg
  location            = local.location
  rg2                 = local.rg2
  secret_id           = "lab04admin"
  key_vault           = local.key_vault
  vnet_name           = azurerm_virtual_network.predayvnet.name
  subnet_cidr         = "172.16.20.0/24"
  security_group_rules  = [
      {
          name                  = "SQL"
          priority              = 100
          protocol              = "tcp"
          destinationPortRange  = "3306"
          direction             = "Inbound"
          access                = "Allow"
      },
      {
          name                  = "deny-the-rest"
          priority              = 200
          protocol              = "*"
          destinationPortRange  = "0-65535"
          direction             = "Inbound"
          access                = "Deny"
      },
  ]

  tags = local.tags
}
