# ARM Templates - LAB 2

To begin this lab, start with the template from the previous lab or use the azuredeploy.json file provided in this folder.

> **NOTE:** Open the 02-Variables folder for this lab

## Add a Virtual Machine to the Template

Add a Virtual Machine resource to the template by adding the code below.  Copy and paste the code at the top of the first resources section in the template.

```json
    {
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2019-06-01",
      "name": "[variables('nicName')]",
      "location": "[parameters('location')]",
      "dependsOn": [ ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": ""
              }
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2019-03-01",
      "name": "linux-vm",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces', variables('nicName'))]"
      ],
      "properties": {
        "hardwareProfile": {
          "vmSize": "Standard_A1_v2"
        },
        "osProfile": {
          "computerName": "linux-vm",
          "adminUsername": "lab2",
          "adminPassword": "this is a bad idea"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "Canonical",
            "offer": "UbuntuServer",
            "sku": "18.04-LTS",
            "version": "latest"
          },
          "osDisk": {
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', variables('nicName'))]"
            }
          ]
        }
      }
    },
```

## Create Variables

Variables provide a simple way to reuse values throughout a template.  To use the new resources, add some variables for the key properties of the template that need to be reused across different resources.  Resource names and resourceIds are common concepts that are reused throughout Azure to associate different resources that are deployed or used together in the same application or environment.

In the variables section of the template add the following code:

```json
    "virtualNetworkName": "virtualNetwork",
    "subnet1Name": "subnet-1",
    "nicName": "networkCard",
    "subnetId": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('virtualNetworkName'), variables('subnet1Name'))]"
```

## Add VM to the Virtual Network

A virtual machine is accessible through a virtual network.  The virtual machine's network card can be attached to the virtual network using the resourceId for a subnet.  Complete the steps below to add the virtual machine to the virtual network:

- Press CTRL+F in VS Code to open the search box
- search for the subnet property of the network card, enter "subnet": (including punctuation) in the search box to find the subnet property
- Change the id property of the subnet to reference the variable defined for the subnetId - don't copy/paste this one, we'll use Visual Studio Code to help author this code
- Place the cursor between the quotes of the id property and type the opening square bracket "[" and then type "v" for variables
- A list will pop up with the option to have VS Code add the variables function - press the enter or tab key to complete the text
- Next press CTRL+SPACE and VS Code will show a list of variables to choose from - select the subnetId with the arrow keys and press enter
- The code should now look like the following:

```json
     "subnet": {
        "id": "[variables('subnetId')]"
      }
```

## View and Set Dependencies

In the first lab we mentioned dependencies to ensure resources are deployed in the correct order.  Note that our template has dependencies to ensure the virtual network is deployed before the virtual machine, since the virtual machine needs to be placed into the virtual network.  Open the search box (CTRL+F) and search for "dependsOn" to see how this is represented in the template.

Next we need to add a dependency to the network card on the subnet.  Since the VM will be placed in a subnet, a dependency is needed to ensure the subnet is deployed before the network card.  Find the dependsOn property for the networkInterfaceCard and add the following code:

```json
        "[variables('virtualNetworkName')]"
```

## Create Parameters

Parameters can be used to make a template more flexible and reusable for multiple users and scenarios.  A simple example is using different credentials for any virtual machine created, i.e. the username and password used to log into the virtual machine.  

Add the following parameters to the template by adding the following code in the parameters section of the template:

```json
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]"
    },
    "adminUsername": {
      "type": "string"
    },
    "adminPassword": {
      "type": "securestring"
    }
```

Update the virtual machine resource to use the new parameters for the username and password. Find the adminUsername property by searching in VS Code.  Replace the hard-coded username with the parameter.

- Remove the text in the adminUsername propery leaving the quotes
- Enter an opening square bracket [ and type param
- You will see an option for VS Code to complete your typing, press tab
- After completion VS Code will show you a list of parameters to choose from (press CTRL+SPACE if you don't see a list), select adminUsername
- Follow the same steps to update the adminPassword property to use the parameter defined for the password

### Use the Location Parameter

A parameter for the location of resources was also defined.  The virtual machine and network card already use this parameter, but the Virtual Network defined does not.  Update the location property on the virtual network to use the location parameter.

## Deploy the Template

Before deploying the template, use VS Code to inspect your template for errors.  Format the code if necessary using SHIFT+ALT+F in VS Code.  

- In the PowerShell command window, verify that your current directory is set to the directory used for this lab before running the following commands.

> **NOTE:**  When deploying the template, you will see a prompt for any parameter vaules that are not provided, for this lab, provide the same values each time you deploy.

PowerShell

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-02-000000 -TemplateFile azuredeploy.json -Verbose
```

Azure CLI

```bash
az group deployment create --resource-group IoC-02-000000 --template-file azuredeploy.json --verbose
```

After the deployment completes, or while the deployment is in process, you can open the Azure Portal and see the resources deployed into your resource group.

## Congratulations

This is the end of this section of the lab.  To see a finished solution, see the final.json file in this folder.
