module "frontend" {
  source = "./modules/azvm"

  host_name     = "web001"
  rg = "" ## Enter the resource group pre-created in your lab
  location      = "East US 2"
  secretId      = "lab04admin"
  keyVault      = "" ## Enter the name of the pre-created key vault instance
  vnet_cidr     = "10.0.0.0/16"
  subnet_cidr   = "10.0.1.0/24"

  tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "5"
  }
}

module "worker" {
  source = "./modules/azvm"
  
  host_name     = "work001"
  rg = "" ## Enter the resource group pre-created in your lab
  location = "East US 2"
  secretId = "lab04admin"
  keyVault = "" ## Enter the name of the pre-created key vault instance
  vnet_cidr     = "10.10.0.0/16"
  subnet_cidr   = "10.10.1.0/24"

  tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "5"
  }
}
