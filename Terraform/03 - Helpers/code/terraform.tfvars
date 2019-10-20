rg = "" ## Enter the resource group pre-created in your lab
location = "" ## Enter the azure region for your resources

custom_rules               = [
      {
        name                   = "http"
        priority               = "100"
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "tcp"
        destination_port_range = "80"
        description            = "HTTP"
      },      
      {
        name                   = "https"
        priority               = "101"
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "tcp"
        destination_port_range = "443"
        description            = "HTTPS"
      },
      { 
        name                   = "deny-the-rest"
        priority               = "300"
        direction              = "Inbound"
        access                 = "Deny"
        protocol               = "tcp"
        destination_port_range = "0-65535"
        description            = "Deny all others"
      }
    ]

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

tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "4"
  }

