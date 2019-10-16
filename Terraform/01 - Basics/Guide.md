# Basics
In this section you will use Terraform to create the fundamental building block of Azure infrastructure - a virtual network. Virtual network (or VNet for short) enables many types of Azure resources, such as virtual machines, to communicate securely with each other, the internet and on-premises network.

## Preliminaries
By now you have already learned that Terraform uses proprietary domain specific language (DSL) to codify cloud resources. This language, called HashiCorp Language, or HCL for short, with its readability and ease of use, is one of the reasons Terraform is so popular. You will use HCL to define a VNet in this section.

Terraform executable evaluates all files within the directory it's being executed against, allowing us to create separate files for each piece of our infrastructure. In this section, we will go ahead and create a separate file for virtual network.

### Create vnet.tf
Using the tool of your choice (VS Code, Visual Studio, command line, vi), create a new file and call it vnet.tf. You will put all the code related to virtual network in this file.

### Resource Group
In the lab environment, you have been given access to a pre-created resource group. To ensure that your infrastructure gets provisioned properly, note the name of the resource group you are using. You will specify it in the VNet provisioning section below.

### Indicate that you will use Azure Terraform provider
Another key Terraform strength is the multitude of providers available for different environments to provision your infrastructure into. Note that does not imply "write infrastructure once, run everywhere," but rather a common syntax used to codify infrastructure, one set per environment.

For our workshop, we will need to indicate that we will be using Terraform provider for Azure. Using [Terraform Azure provider documentation](https://www.terraform.io/docs/providers/azurerm/index.html), locate the block of HCL code that specifies the use of Azure provider for Terraform and paste it inside the vnet.tf.

## VNet concepts
With preliminaries out of the way, you are ready to provision your virtual network. A quick review of basic VNet concepts below:

**Address space**: When creating a VNet, you must specify a custom private IP address space using public and private (RFC 1918) addresses. Azure assigns resources in a virtual network a private IP address from the address space that you assign. For example, if you deploy a VM in a VNet with address space, 10.0.0.0/16, the VM will be assigned a private IP like 10.0.0.4.

**Subnets**: Subnets enable you to segment the virtual network into one or more sub-networks and allocate a portion of the virtual network's address space to each subnet. You can then deploy Azure resources in a specific subnet. Just like in a traditional network, subnets allow you to segment your VNet address space into segments that are appropriate for the organization's internal network. This also improves address allocation efficiency. You can secure resources within subnets using Network Security Groups, which you will do later in today's workshop.

**Regions**: VNet is scoped to a single region/location; however, multiple virtual networks from different regions can be connected together using Virtual Network Peering.

**Subscription**: VNet is scoped to a subscription. You can implement multiple virtual networks within each Azure subscription and Azure region.

## Create VNet
Using [Terraform Azure provider documentation for virtual network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html), define VNet with the following parameters:

```name``` should be "tfignitepreday"
```location``` should be "East US 2"
```resource_group_name``` should be set to the name of the resource group created specifically for you in the demo environment (noted previously)
```address_space``` should be set to "10.0.0.0/16"

## Create Subnet within VNet

## Plan your infrastructure via 'terraform plan'

## Create your infrastructure via 'terraform apply'
