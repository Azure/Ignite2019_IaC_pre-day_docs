# ARM Templates - LAB 1

This lab will walk through using Azure Resource Manager Templates to deploy resources to an Azure Resource Group.  Start by using the azuredeploy.json file and make the changes documented below to complete the lab.

## Clone the Repo

To start the lab, clone the repo that contains the lab content.  

- Open Visual Studio Code from the desktop
- Press F1 and type **Git Clone** in the command box and press **Enter**
- For the repository URL enter: https://github.com/Azure/Ignite2019_IaC_pre-day_docs and press **Enter**
- Select a location for the repo, and open the folder when prompted by VS Code

## Import WhatIf Module

For this lab there will be a ***preview*** of the "WhatIf" feature for ARM Templates.  Before running any commands import the preview modules for PowerShell.

- Open a PowerShell command window
- Change the current directory to the directory used for cloning the lab repo, if you used the default this will be **C:\Users\demouser\Ignite2019_IaC_pre-day_docs\ARM Template**
- Run the script to import the preview modules: **import.ps1**

> **NOTE:** If you close the PowerShell window you will need to re-run these commands before using the WhatIf feature.

## Deploy an Empty Template

Before getting started in the lab, deploy the empty template to get familiar with the command line tools available for Azure.  Open a PowerShell command window to run all of the commands provided for the labs.

### Login to Azure

For the course of the lab you can use PowerShell, the Azure CLI or a combination of both if you want to become familiar with each.  You will need to login to PowerShell and the CLI using your lab credentials for whichever you use.  If you want to use both tools, run both login commands; if you choose only one tool, you only need to run that login command.  You will be prompted for steps to authenticate after running the command.  Use the credentials provided for the lab environment.

PowerShell

```PowerShell
Connect-AzAccount
```

Azure CLI

```bash
az login
```

### Deploy the Template

A template will typically deploy a set of resources to a resource group.  An empty resource group is available for this lab, the name of the resource group will use part of your userId so you will need to update the commands below to use the correct resource group name for your user instead of "IoC-02-000000".

> **NOTE:** For each step of the lab run the commands from the directory that contains the lab files, for example **C:\Users\demouser\Ignite2019_IaC_pre-day_docs\ARM Template\01 - Basics**

To deploy the template run the following command:

PowerShell

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-02-000000 -TemplateFile azuredeploy.json -Verbose
```

Azure CLI

```bash
az group deployment create --resource-group IoC-02-000000 --template-file azuredeploy.json --verbose
```

You will see the status of the deployment in the command window.  Since this template is empty, no resources are created and the deployment will finish quickly.

## Add a Virtual Network

Return to VS Code and open the **azuredeploy.json** file in the **01 - Basics** folder. Next, add a virtualNetwork to the template.  When adding resources there are a number of sources of information and samples you can use to start creating templates.

The [Azure QuickStart Repo](https://github.com/Azure/azure-quickstart-templates) has hundreds of samples and a searchable index can be found at [azure.com](https://azure.microsoft.com/en-us/resources/templates).  For this lab we provide snippets that you can use to construct your template.

The first resource to add is a virtual network.  Copy the code below and paste between the square brackets in the resources section of the template.

```json
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2019-06-01",
      "name": "virtualNetwork",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "10.0.0.0/16"
          ]
        },
        "subnets": [
          {
            "name": "subnet-1",
            "properties": {
              "addressPrefix": "10.0.0.0/24"
            }
          }
        ]
      }
    }
```

After pasting code or editing a template, you can use VS Code to format the code to make it consistent and easy to read.  Press SHIFT+ALT+F in VS Code to format the template. Next, save the template.

## Deploy the Virtual Network

To deploy the template run the following command:

PowerShell

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-02-000000 -TemplateFile azuredeploy.json -Verbose
```

Azure CLI

```bash
az group deployment create --resource-group IoC-02-000000 --template-file azuredeploy.json --verbose
```

After the deployment go to the Azure Portal to see the virtual network created in the resource group.  Find the virtual network and view the subnet created. You can also use the following commands:

PowerShell

```PowerShell
Get-AzVirtualNetwork -ResourceGroupName IoC-02-000000
```

Azure CLI

```bash
az network vnet list -g IoC-02-000000 -o table
```

Note that there is only one subnet in the virtual network.

## Add a Subnet

Next, add a second subnet to the virtual network in the template.  Copy the code below and paste it before the first subnet declaration.  Note, that the order of the resources in the template does not matter but you can specify dependencies as needed.  Dependencies will be covered in a later step.

```json
          {
            "name": "subnet-2",
            "properties": {
              "addressPrefix": "10.0.1.0/24"
            }
          },
```

Save the changes to the template.

## Deploy the Template with the New Subnet

Azure Resource Manager Templates are declarative in nature and define a goal state or end state for Azure to meet.  When a template is deployed after a previous deployment, Azure will look for any changes need to match the newly defined state.

When deploying this template a second time, the virtual network will be updated to add the second subnet defined in the template.

Use the same command you used in the previous deployment.  You will use this same command, each time you deploy the template.

After deployment is finished, view the virtual network as in the previous step and confirm that the second subnet has been added.

## Congratulations

This is the end of this section of the lab.  To see a finished solution, see the final.json file in this folder.
