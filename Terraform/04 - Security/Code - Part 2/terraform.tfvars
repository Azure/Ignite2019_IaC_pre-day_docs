rg = "" ## Enter the resource group pre-created in your lab
location = "" ## Enter the azure region for your resources
securityGroupRules = [
      {
          name                  = "DNS"
          priority              = 100
          protocol              = "*"
          destinationPortRange  = "53"
      },
      {
          name = "HTTPS"
          priority              = 150
          protocol              = "tcp"
          destinationPortRange  = "443"
      },
      {
          name = "WHOIS"
          priority              = 200
          protocol              = "tcp"
          destinationPortRange  = "43"
      },
  ]
secretId = "lab04admin"
keyVault = "" ## Enter the name of the pre-created key vault instance
rg2 = "" ## Enter the name of the resource group where key vault exists
tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "4"
  }