rg = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>" ## Enter the resource group pre-created in your lab
location = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>" ## Enter the azure region for your resources 

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

tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "4"
  }

