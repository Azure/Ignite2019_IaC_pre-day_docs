# Variables
In this section you will build upon the infrastructure (VNet + subnet) you created earlier by creating a virtual machine and adding a network interface to it to allow that virtual machine to communicate with the outside world. After creating this additional infrastructure, you will learn how to define and use variables inside your Terraform code to parameterize resources. You will also learn how Terraform refers to resources internally and is able to construct a dependency graph (Directed Acyclic Graph, or a DAG for the comp sci majors) without explicitly specifying it.

## Create nic.tf
To make our virtual machine accessible to the outside world, we will need to add a Network Interface to it. Network Interface is a separate resource in Azure. Following the pattern from the previous walk-through of creating a separate file for each resource, create a new file and call it ```nic.tf```. You will put all the code related to network interface in this file.

Since your network interface will need to be associated to a VNet, you will need to refer to the VNet we have previously created. In Terraform, you do this by specifying the internal identifier of the resourse. Remember the line

```resource "azurerm_virtual_network" "predayvnet" {```

On this line, the first word (resource) is a standard word indicating new resource creation. The second word ("azurerm_virtual_network) is the type of resource we were defining - VNet in that case. The third word (predayvnet) is the internal identifier for the VNet. We will use this identifier inside Terraform scripts to refer to that VNet.

Now, using [Terraform Azure provider documentation for network interface](https://www.terraform.io/docs/providers/azurerm/r/network_interface.html), locate the block of code that creates a network interface with the following parameters:

```
  name                = "tfignitepredaynic"
  location            = "East US 2"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"

  ip_configuration {
    name                          = "tfpredaynicconfig"
    subnet_id                     = "azurerm_subnet.test.id"
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "staging"
  }
}
```

## Cheat Sheet: nic.tf
<details>
<summary>
Expand for nic.tf code
</summary>

```
#Configure Network Interface
resource "azurerm_network_interface" "example" {
  name                = "tfignitepredaynic"
  location            = "var.location"
  resource_group_name = "var.my_resource_group"

  ip_configuration {
    name                          = "tfpredaynicconfig"
    subnet_id                     = "azurerm_subnet.predayvnet.subnets[0]}"
    private_ip_address_allocation = "Dynamic"
  }
}
```
</details>

## Create vm.tf
Again, following the pattern of creating a separate file for each resource, create a new file and call it ```vm.tf```. You will put all the code related to virtual machine in this file.

Now, using [Terraform Azure provider documentation for virtual machined](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html), locate the block of code that creates a virtual machine with the following parameters:

```
  name                  = "tfignitepredayvm"
  location              = "East US 2"
  resource_group_name   = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  vm_size               = "Standard_DS1_v2"

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
```

Make sure to save all the files you were working with before the following step.


## Cheat Sheet: vm.tf
<details>
<summary>Expand for vm.tf code</summary>

```
resource "azurerm_virtual_machine" "example" {
  name                  = "tfignitepredayvm"
  location              = "var.location"
  resource_group_name   = "var.my_resource_group"
  vm_size               = "Standard_DS1_v2"

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
}
```
</details>


## Introducing Variables
By now, you have seen how you had to specify the same exact value for location to deploy infrastructure into three times. That's three times you could have misspelled it or misconfigured the infrastructure by deploying it into different regions. Finally, if you wanted to change the Azure region to deploy into, you will have to change it in at three different places.

To help you avoid all those potential issues, Terraform allows you to define and use variables. A good practice to follow is to put variables into a separate file called (by convention, not a requirement) variables.tf.

### Create variables.tf
Create a new ```variables.tf``` file. A variable is defined via the keyword (intuitively enough) ***variable***, like the following:

```
variable "location" {
  description = "Azure region to put resources in"
  default     = "East US"
}
```
Go ahead and put the variable definition from above into your variables.tf file. Additionally, create another variable called ```my_resource_group``` with the value of the resource group you have been assigned to work in.

### Using variables
You use variables by prefixing their name with the keyword ```var```, like below:

```  
location            = "var.location"
```

Go ahead and replace all previously hard-coded values for Azure regions and resource group name with variable definition.

## Cheat Sheet: variables.tf
<details>
<summary>Expand for variables.tf code</summary>

```
variable "my_resource_group" {
  description = "Resource group to put resources into"
  default     = "<<<NAME OF YOUR RESOURCE GROUP>>>"
}

variable "location" {
  description = "Azure region to put resources in"
  default     = "East US"
}
```
</details>

## Plan your infrastructure via 'terraform plan'
Now you are ready once again to plan and deploy the infrastructure into Azure. From the console window within the folder with all the .tf files, go ahead and execute the following command:

```terraform plan```

You will deploy your VM in the next step.

## Create your infrastructure via 'terraform apply'
If the output of ```terraform plan``` looks good to you, go ahead and issue the following command:

```terraform plan```

Finally, confirm that you do want the changes deployed.

Congratulations, you have just created the virtual machine with a network interface in Azure and associated it to the existing VM! In the next section, you will learn how to secure your infrastructure using Terraform while also learning about iterators in helper functions in HCL.
