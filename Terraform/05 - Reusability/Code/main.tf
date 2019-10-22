# Define local variable for use in resources and modules
locals {
  location          = "East US 2"
  rg                = "" ## Enter the resource group pre-created in your lab
  keyVault          = "" ## Enter the name of the pre-created key vault instance
  tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "5"
  }
}

# Configure Vnet
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
  location            = "East US 2"
  secretId            = "lab04admin"
  keyVault            = local.keyVault
  vnet_name           = azurerm_virtual_network.predayvnet.name
  subnet_cidr         = "172.16.10.0/24"
  securityGroupRules  = [
      {
          name                  = "HTTP"
          priority              = 100
          protocol              = "tcp"
          destinationPortRange  = "80"
      },
      {
          name = "SSH"
          priority              = 150
          protocol              = "tcp"
          destinationPortRange  = "22"
      }
  ]

  tags                = local.tags
}

module "mysql_db" {
  source = "./modules/azvm"
  
  host_name           = "mysql001"
  rg                  = local.rg
  location            = "East US 2"
  secretId            = "lab04admin"
  keyVault            = local.keyVault
  vnet_name           = azurerm_virtual_network.predayvnet.name
  subnet_cidr         = "172.16.20.0/24"
  securityGroupRules  = [
      {
          name                  = "SQL"
          priority              = 100
          protocol              = "tcp"
          destinationPortRange  = "3306"
      },
  ]

  tags = local.tags
}
