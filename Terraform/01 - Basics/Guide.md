# Basics
In this section you will use Terraform to create the fundamental building block of Azure infrastructure - a virtual network. Virtual network (or VNet for short) enables many types of Azure resources, such as virtual machines, to communicate securely with each other, the internet and on-premises network.

## Preliminaries
By now you have already learned that Terraform uses proprietary domain specific language (DSL) to codify cloud resources. This language, called HashiCorp Language, or HCL for short, with its readability and ease of use, is one of the reasons Terraform is so popular. You will use HCL to define a VNet in this section.

Terraform executable evaluates all files within the directory it's being executed against, allowing us to create separate files for each piece of our infrastructure. In this section, we will go ahead and create a separate file for virtual network.

### Indicate that you will use Azure Terraform provider
Another key Terraform strength is the multitude of providers available for different cloud environments for infrastructure provisioning. Note that does not imply "write infrastructure once, run everywhere," but rather a common syntax used to codify infrastructure, one set per environment.

For our workshop, we will need to specify that we will be using Terraform provider for Azure. First, following Terraform best practices, create a new file that will contain the code indicating the use of Azure provider. Give this new file a name ```provider.tf```. Then, using [Terraform Azure provider documentation](https://www.terraform.io/docs/providers/azurerm/index.html), locate the block of HCL code that specifies the use of Azure provider for Terraform, paste it inside provider.tf and save the file.

### Create vnet.tf
Using the tool of your choice (VS Code, Visual Studio, command line, vi), create a new file and call it vnet.tf. You will put all the code related to virtual network in this file.

### Resource Group
In the lab environment, you have been given access to a pre-created resource group. To ensure that your infrastructure gets provisioned properly, note the name of the resource group you are using. You will specify it in the VNet provisioning section below.

## VNet concepts
With preliminaries out of the way, you are ready to provision your virtual network. A quick review of basic VNet concepts below:

**Address space**: When creating a VNet, you must specify a custom private IP address space using public and private (RFC 1918) addresses. Azure assigns resources in a virtual network a private IP address from the address space that you assign. For example, if you deploy a VM in a VNet with address space, 10.0.0.0/16, the VM will be assigned a private IP like 10.0.0.4.

**Subnets**: Subnets enable you to segment the virtual network into one or more sub-networks and allocate a portion of the virtual network's address space to each subnet. You can then deploy Azure resources in a specific subnet. Just like in a traditional network, subnets allow you to segment your VNet address space into segments that are appropriate for the organization's internal network. This also improves address allocation efficiency. You can secure resources within subnets using Network Security Groups, which you will do later in today's workshop.

**Regions**: VNet is scoped to a single region/location; however, multiple virtual networks from different regions can be connected together using Virtual Network Peering.

**Subscription**: VNet is scoped to a subscription. You can implement multiple virtual networks within each Azure subscription and Azure region.

## Create VNet
Using [Terraform Azure provider documentation for virtual network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html), define VNet with the following properties:

```name``` should be "tfignitepreday"
```location``` should be "East US 2"
```resource_group_name``` should be set to the name of the resource group created specifically for you in the demo environment (noted previously)
```address_space``` should be set to "10.0.0.0/16"

## Create Subnet within VNet
Using [Terraform Azure provider documentation for virtual network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html), define a new subnet within the VNet with the following properties:

```name``` should be "subnet1"
```address_prefix``` should be "10.0.1.0/24"

Make sure to save vnet.tf before the following step.

## Plan your infrastructure via 'terraform plan'
Now you are ready to plan and deploy the VNet and the associated subnet into Azure. From the console window within the folder where vnet.tf and provider.tf reside, go ahead and execute the following command:

```terraform plan```

This command allows you to visualize infrastructure changes about to be deployed into Azure. This command does not perform any actual infrastructure deployment. You will deploy your VNet in the next step.

## Create your infrastructure via 'terraform apply'
Terraform ```apply``` command provisions the infrastructure into the cloud. If the output of ```terraform plan``` looks good to you, go ahead and issue the following command:

```terraform plan```

Finally, confirm that you do want the changes deployed.

Congratulations, you have just created the first fundamental building block of your infrastructure!

## Cheat Sheet: provider.tf
<details>
<summary>
Expand for provider.tf code
</summary>
`
# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.34.0"
}
`
</details>

## Cheat Sheet: vnet.tf
<details>
<summary>Expand for vnet.tf code</summary>

```
resource "azurerm_virtual_network" "test" {
  name                = "tfignitepreday"
  location            = "East US 2"
  resource_group_name = "<<<NAME OF YOUR RESOURCE GROUP>>>"
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
```
</details>
