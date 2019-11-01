# Terraform Lab 1 - Basics
In this section you will use Terraform to create the fundamental building block of Azure infrastructure - a virtual network. Virtual network (or VNet for short) enables many types of Azure resources, such as virtual machines, to communicate securely with each other, the internet and on-premises network.

## Before diving into Terraform let's get things set up

Create a folder on the lab virtual machine where you will save your Terraform configuration.

We recommend using VS Code for creating Terraform configurations in this lab so open VS Code and browse to the folder that you created for your configurations. 

[Azure Terraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform) and [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform) extensions are required and already installed in your VS Code environment. The [Install and use the Azure Terraform Visual Studio Code extension](https://docs.microsoft.com/en-us/azure/terraform/terraform-vscode-extension) provides good guidance on what you need to do to get started. 

In short (TL;DR):
- To run the configuration in Cloud Shell simply ensure your configuration is open in VS Code and a Terraform configuration file is selected; from the menu bar, select View > Command Palette... > Azure Terraform: push.
- If you have not logged in, the Azure Account extension will prompt you to sign in.
- Terraform files are copied to the `clouddrive` folder in Cloud Shell upon saving so you don't need to explicitly copy files to Cloud Shell in order to run them there unless otherwise stated in the lab.
- ALL Terraform execution including init, plan and apply will be **run from within Azure Cloud Shell** after pushing the files up.

> **NOTE**: The first time you launch Cloud Shell from a new folder, you will be asked to set up the web application. Select Open to continue

## Preliminaries
By now you have already learned that Terraform uses proprietary domain specific language (DSL) to codify cloud resources. This language, called HashiCorp Language, or HCL for short, with its readability and ease of use, is one of the reasons Terraform is so popular. You will use HCL to define a VNet in this section.

Terraform executable evaluates all files within the directory it's being executed against, allowing us to create separate files for each piece of our infrastructure. In this section, we will go ahead and create a separate file for virtual network.

### Indicate that you will use Azure Terraform provider
Another key Terraform strength is the multitude of providers available for different cloud environments for infrastructure provisioning. Note that does not imply "write infrastructure once, run everywhere," but rather a common syntax used to codify infrastructure, one set per environment.

For our workshop, we will need to specify that we will be using Terraform provider for Azure. First, following Terraform best practices, create a new file that will contain the code indicating the use of Azure provider. Give this new file a name `provider.tf`. Then, using [Terraform Azure provider documentation](https://www.terraform.io/docs/providers/azurerm/index.html), locate the block of HCL code that specifies the use of Azure provider for Terraform, paste it inside provider.tf and save the file. In this lab, you will need to use at least version 1.35.0 of the provder.

## Cheat Sheet: provider.tf
<details>
<summary>
Expand for provider.tf code
</summary>

```
# Configure the Azure Provider
provider "azurerm" {
  version = "~>1.35.0"
}
```
</details>

### Create vnet.tf
Create a new file and called ```vnet.tf```. You will put all the code related to virtual network in this file.

### Resource Group
In the lab environment, you have been given access to a pre-created resource group. To ensure that your infrastructure gets provisioned properly, note the name of the resource group titled "Second Resource Group Name" in your lab environment details. You will specify it in the VNet provisioning section below.

## VNet concepts
With preliminaries out of the way, you are ready to provision your virtual network. A quick review of basic VNet concepts below:

**Address space**: When creating a VNet, you must specify a custom private IP address space using public and private (RFC 1918) addresses. Azure assigns resources in a virtual network a private IP address from the address space that you assign. For example, if you deploy a VM in a VNet with address space, 10.0.0.0/16, the VM will be assigned a private IP like 10.0.0.4.

**Subnets**: Subnets enable you to segment the virtual network into one or more sub-networks and allocate a portion of the virtual network's address space to each subnet. You can then deploy Azure resources in a specific subnet. Just like in a traditional network, subnets allow you to segment your VNet address space into segments that are appropriate for the organization's internal network. This also improves address allocation efficiency. You can secure resources within subnets using Network Security Groups, which you will do later in today's workshop.

**Regions**: VNet is scoped to a single region/location; however, multiple virtual networks from different regions can be connected together using Virtual Network Peering.

**Subscription**: VNet is scoped to a subscription. You can implement multiple virtual networks within each Azure subscription and Azure region.

## Create VNet
Using [Terraform Azure provider documentation for virtual network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html), define VNet with the following properties:

```
name should be "tfignitepreday"
resource_group_name should be set to the name of the resource group created specifically for you in the demo environment (noted previously)
location should be set to the region where your resouce group resides
address_space should be set to "10.0.0.0/16"
```

## Create Subnet within VNet
Using [Terraform Azure provider documentation for virtual network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html), define a new subnet within the VNet with the following properties:

```
name should be "subnet1"
address_prefix should be "10.0.1.0/24"
```

Make sure to save vnet.tf before the following step.

## Cheat Sheet: vnet.tf
<details>
<summary>Expand for vnet.tf code</summary>

```
resource "azurerm_virtual_network" "predayvnet" {
  name                = "tfignitepreday"
  location            = "<<<REGION OF YOUR ASSIGNED RESOURCE GROUP>>>"
  resource_group_name = "<<<NAME OF YOUR ASSIGNED RESOURCE GROUP>>>"
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
```
</details>

>**NOTE** Prior to running any Terraform commands in Azure Cloud Shell, make sure that you select View > Command Palette... > Azure Terraform: push in order to push your latest changes up to your cloud shell environment. 

## Initialize your Terraform environment
Before provisioning your environement, you need to ensure that Terraform is initialized using the [init command](https://www.terraform.io/docs/commands/init.html). This process will initialize a working directory containing Terraform configuration files.

```terraform init```

## Plan your infrastructure via 'terraform plan'
Now you are ready to plan and deploy the VNet and the associated subnet into Azure. From the console window within the folder where vnet.tf and provider.tf reside, go ahead and execute the following command:

```terraform plan -out tfplan```

This command allows you to visualize infrastructure changes about to be deployed into Azure. This command does not perform any actual infrastructure deployment. You will deploy your VNet in the next step.

Review the plan in Cloud Shell to ensure that exactly 1 resource will be added and the properties are what you expect. You should see output similar to the following:

```terraform
Terraform will perform the following actions:

  # azurerm_virtual_network.predayvnet will be created
  + resource "azurerm_virtual_network" "predayvnet" {
      + address_space       = [
          + "10.0.0.0/16",
        ]
      + id                  = (known after apply)
      + location            = "eastus2"
      + name                = "tfignitepreday"
      + resource_group_name = "IoC-02-109672"
      + tags                = (known after apply)

      + subnet {
          + address_prefix = "10.0.1.0/24"
          + id             = (known after apply)
          + name           = "subnet1"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

## Create your infrastructure via 'terraform apply'
Terraform ```apply``` command provisions the infrastructure into the cloud. If the output of ```terraform plan``` looks good to you, go ahead and issue the following command:

```terraform apply tfplan```

Finally, confirm that you do want the changes deployed by browsing to your resource group from [portal.azure.com](https://portal.azure.com). 

>**NOTE** Since Terraform is idempotent, if you run Terraform plan again after successsfully applying the configuration, you will notice that it will state that no changes are required and that your infrastructure is up to date.

You can also review the complete code we have created for this section in the [Code folder](https://github.com/Azure/Ignite2019_IaC_pre-day_docs/tree/master/Terraform/01%20-%20Basics/Code).

Congratulations, you have just created the first fundamental building block of your infrastructure!
