# Iterators and Helpers
In the previous lessons, you have created a Virtual Network, a subnet, and a Virtual Machine within that subnet in Azure. You learned how to parameterize Terraform code to increase code stability and reusability. In this walk-through, you will secure this infrastructure while learning how to use iterators and helper functions in Terraform to help with that task.

By default, all inbound traffic originating from outside of your Virtual Network into your subnet is denied, while your Virtual Machine has outbound Internet access. These default rules might be acceptable if you had just one subnet, but that is not a real-world scenario. One of the common scenarios in cloud infrastructure is to have infrastructure tiers, such as database tier, backend tier, and a web tier, all with their own set of security policies. Let's update our infrastructure with a new subnet representing the web tier and then we will secure it.

## Update vnet.tf
Using the same process as in Lesson 2, go ahead and add another subnet to the Virtual Network you created with the following properties:

1. Set internal identifier as "predaywebsubnet"
1. Set the resource group and the virtual network name to be the same as the other subnet
1. Set address prefix as "10.0.2.0/24"

Save your changes before moving onto the next part - securing your subnet.

## CHEAT SHEET
<details>
<summary>
Expand for updated vnet.tf code
</summary>

```terraform
# Configure Subnet
resource "azurerm_subnet" "predaywebsubnet" {
  name                 = "web"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.predayvnet.name
  address_prefix       = "10.0.2.0/24"
}
```
</details>

## Intro to iterators in Terraform
Iterators help us create many copies of the same resource with a single line of code. In the simplest example, let's say your virtual machine needs to have 3 identical data disks, equivalent in size and type, and different in name. One way to accomplish this would be to copy and paste code blocks creating those disks; a much easier way, however, would be to use the "count" keyword inside the infrastructure configuration, like this

```terraform
resource "azurerm_managed_disk" "mydatadisks" {
  count                = "3"
  name                 = "disk1" + count.index
  location             = var.rg
  resource_group_name  = var.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 30
}
```

Note the use of the count property to specify the number of data disks we need, and then the use of count.index, which returns the running value for the count, to give a unique name for each data disk.

The simple example above works for the infrastructure that is not parameterized the way you learned in Lesson 2; it would be preferred if we isolated as many  parameters as possible for easier maintenance, and then iterated over those parameters. Let's do this with the security rules we want to introduce for the "web" subnet we created in this lesson.

## Define security rules
The rules for the "web" subnet are pretty straightforward: deny all inbound Internet traffic except for http and https. Since the rules will be evaluated based on the priority value, we want to make sure that Allow rules for http and https get higher priority than the Deny rule. Let's go ahead and paste the security rules variable into our variables.tf code:

```terraform
variable "custom_rules" {
  description = "Security rules for the network security group"
  type        = "list"
  default     = []
}
```

and then provide the value for that list in variables.tf

```terraform
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
```

Note the use of "[]" to define the variable as type list - a list of security rules.

## Create networksecurity.tf
With rules defined in our variable, it is time to use iterators and helper functions to define the Azure resources based on those variables. First, we'll use the helper *length* function - this function returns the number of elements in the list, which is the number of rules we have created. We will also use the *lookup* helper function to retrieve value from the list. 

But first we need to create a network security group to associate the rules with. Go ahead and create it via the following code:

```terraform
resource "azurerm_network_security_group" "nsgsecureweb" {
  name                = "secureweb"
  location            = var.location
  resource_group_name = var.rg
}
```

Next, go ahead and create a new file called networksecurity.tf and paste the following code in there:

```terraform
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
```

With network rules created and associated to the network security group, we proceed to final step - associating network security group with the web subnet.

## Update vnet.tf - Part 2
Update the web subnet definition to use the "nsgsecureweb" security group we created, like this:

```terraform
    network_security_group_id = azurerm_network_security_group.nsgsecureweb.id
```

and then also create a new resource finalizing the association (this is a forward-looking feature for the next generation of Terraform provider for Azure)

```terraform
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.predaywebsubnet.id
  network_security_group_id = azurerm_network_security_group.nsgsecureweb.id
}
```

## Plan your infrastructure via 'terraform plan'
Now you are ready once again to plan and deploy the infrastructure into Azure. From the console window within the folder with all the .tf files, go ahead and execute the following command:

```terraform plan```

You will deploy your security group and rules in the next step.

## Create your infrastructure via 'terraform apply'
If the output of ```terraform plan``` looks good to you, go ahead and issue the following command:

```terraform plan```

Finally, confirm that you do want the changes deployed.

Congratulations, you have just secured your infrastructure and learnt to use iterators and helpers to to it for maintainability and scalability in the future! In the next section, you will learn how to further secure your infrastructure using Azure Key Vault.

