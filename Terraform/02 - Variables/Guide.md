# Terraform Lab 2 - Variables
In this section you will build upon the infrastructure (VNet + subnet) you created earlier by creating a virtual machine and adding a network interface to it to allow that virtual machine to communicate with the outside world. After creating this additional infrastructure, you will learn how to define and use variables inside your Terraform code to parameterize resources. You will also learn how Terraform refers to resources internally and how it is able to construct a dependency graph (Directed Acyclic Graph, or a DAG for the comp sci majors) without explicitly defining it.

## Update vnet.tf

In this lab you will be creating relationships between Terraform resources. The first of which will occur in the next part of this lab where you will "link" the Network Interface resource (or NIC) to the subnet that has already been created in the virtual network from the previous lab. To do this you will define an [expression](https://www.terraform.io/docs/configuration/expressions.html) that references data, specifically the subnet id, exported by the subnet resource. In order to make this easier you will pull the subnet out of the virtual network resource and define it in its own Terraform resource using the [```azurerm_subnet```](https://www.terraform.io/docs/providers/azurerm/r/subnet.html) resource.

Update your vnet.tf file as follows:
1. Create a new `azurerm_subnet` resource named "*predaysubnet*" using the same properties that you have in the `subnet` block from the `azurerm_virtual_network` resource.
1. Add the required `virtual_network_name` property to the `azurerm_subnet` resource using the expression value of `azurerm_virtual_network.predayvnet.name`. 
1. Add the `resource_group_name` to the `azurerm_subnet` resource.
1. Delete the entire `subnet` block from the `azurerm_virtual_network` resource.

>**NOTE**: Moving the subnet from the `azurerm_virtual_network` to its own `azurerm_subnet` will NOT result in a change to Azure, however, doing this allows you to refer to the subnet id property using the expression `azurerm_subnet.predaysubnet.id` rather than a much more complicated expression.

## CHEAT SHEET
<details>
<summary>
Expand for updated vnet.tf code
</summary>

```terraform
# Configure Vnet -- pull subnet out to its own resource to demonstrate references / dependencies
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  address_space       = ["10.0.0.0/16"]
}

# Configure Subnet
resource "azurerm_subnet" "predaysubnet" {
  name                 = "subnet1"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  virtual_network_name = azurerm_virtual_network.predayvnet.name
  address_prefix       = "10.0.1.0/24"
}
```
</details>

## Create nic.tf
To make our virtual machine accessible to the outside world, we will need to add a Network Interface to it. Network Interface is a separate resource in Azure. Following the pattern from the previous walk-through of creating a separate file for each resource, create a new file and call it ```nic.tf```. You will put all the code related to network interface in this file.

Since your network interface will need to be associated to a VNet, you will need to refer to the VNet we have previously created. In Terraform, you do this by specifying the internal identifier of the resourse. Remember the line

```resource "azurerm_virtual_network" "predayvnet" {```

On this line, the first word `resource` is a reserved word indicating new resource creation. The second word `azurerm_virtual_network` is the type of resource we were defining - VNet in that case. The third word `predayvnet` is the internal identifier for the VNet. We will use this identifier inside Terraform scripts to refer to that VNet.

Now, using [Terraform Azure provider documentation for network interface](https://www.terraform.io/docs/providers/azurerm/r/network_interface.html), locate the block of code that creates a network interface with the following parameters:

```terraform
  name                = "tfignitepredaynic"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"

  ip_configuration {
    name                          = "tfpredaynicconfig"
    subnet_id                     = azurerm_subnet.predaysubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

## CHEAT SHEET
<details>
<summary>
Expand for nic.tf code
</summary>

```terraform
#Configure Network Interface# Configure Network Interface
resource "azurerm_network_interface" "predaynic" {
  name                = "tfignitepredaynic"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"

  ip_configuration {
    name                          = "tfpredaynicconfig"
    subnet_id                     = azurerm_subnet.predaysubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
```
</details>

## Create vm.tf
Again, following the pattern of creating a separate file for each resource, create a new file and call it ```vm.tf```. You will put all the code related to virtual machine in this file.

Now, using [Terraform Azure provider documentation for virtual machine](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html), locate the block of code that creates a virtual machine with the following parameters:

```terraform
  name                  = "tfignitepredayvm"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name   = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.predaynic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
```

Make sure to save all the files you were working with before the following step.


## CHEAT SHEET
<details>
<summary>Expand for vm.tf code</summary>

```terraform
# Configure Virtual Machine
resource "azurerm_virtual_machine" "predayvm" {
  name                  = "tfignitepredayvm"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name   = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.predaynic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
```
</details>


## Introducing Variables
By now, you have seen how you had to specify the same exact value for location and resource group to deploy infrastructure in multiple places. That's multiple times where you could have misspelled it or misconfigured the infrastructure by deploying it into different regions. Finally, if you wanted to change the Azure region to deploy into, you will have to change it in many different places.

To help you avoid all those potential issues, Terraform allows you to define and use [input variables](https://www.terraform.io/docs/configuration/variables.html). A good practice to follow is to put variables into a separate file called (by convention, not a requirement) variables.tf.

### Create variables.tf
Create a new `variables.tf` file. A variable is defined via the keyword (intuitively enough) ***variable***, like the following:

```terraform
variable "location" {
  type        = string
  description = "Azure region to put resources in"
}
```
Go ahead and put the variable definition from above into your variables.tf file. Additionally, create another variable called `rg` using the type string as well.

### Create terraform.tfvars

A good practice to follow for entering variable values that are not secrets, is to put them into a separate file called ```terraform.tfvars```. If you name the file something other than this, you will need to pass it into the commandline parameter `var-file`. The contents of this file is simply a set of keys (matching the variable names) with values as follows:

```terraform
location = "East US 2"
```

Go ahead and put the variable values for your variables "location" and "rg" into your terraform.tfvars file. 


### Using variables
You use variables by prefixing their name with the keyword `var`, like below:

```terraform
location            = var.location
```

Go ahead and replace all previously hard-coded values for Azure regions and resource group name with variable definition.

> **HINT** you should have replaced the location for 3 resources and resource group for all 4 resources.

## CHEAT SHEETS
<details>
<summary>Expand for variables.tf code</summary>

```terraform
variable "rg" {
  type        = "string"
  description = "Name of Lab resource group to provision resources to."
}

variable "location" {
  type        = "string"
  description = "Azure region to put resources in"
}
```
</details>

<details>
<summary>Expand for terraform.tfvars code</summary>

```terraform
rg = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
location = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
```
</details>

> **NOTE** Remember to push your changes to Azure Cloud Shell before moving on to the next steps.

## Plan your infrastructure via 'terraform plan'
Now you are ready once again to plan and deploy the infrastructure into Azure. From the console window within the folder with all the .tf files, go ahead and execute the following command:

```terraform plan -out tfplan```

You Terraform plan should state that you have only have 2 resources to add. 

You will deploy your VM in the next step.

## Create your infrastructure via 'terraform apply'
If the output of ```terraform plan``` looks good to you, go ahead and issue the following command:

```terraform apply tfplan```

Finally, confirm that you do want the changes deployed.

You can also review the complete code we have created for this section in the [Code folder](https://github.com/Azure/Ignite2019_IaC_pre-day_docs/tree/master/Terraform/02%20-%20Variables/Code).

Congratulations, you have just created the virtual machine with a network interface in Azure and associated it to the existing VM! In the next sections, you will learn how to secure your infrastructure using Terraform while also learning about iterators in helper functions in HCL.
