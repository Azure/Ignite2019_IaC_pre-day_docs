# LAB 2 - Azure Resource Manager Templates

To begin this lab, start with the template from the previous lab or use the azuredeploy.json file provided in this folder.

## Add a Virtual Machine to the Template

To start this lab you can open the completed azuredeploy.json file from the previous lab or start with the one in this folder. Nextm add a Virtual Machine resource to the template by adding the code below.  Copy and paste the code at the top of the first resources section in the template.

```json
    {
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2019-06-01",
      "name": "[variables('nicName')]",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/virtualNetworks', variables('virtualNetworkName'))]"
      ],
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

To use the new resources add some variables for the key pieces of the template that need to be reused across different resources.  Resource names and resourceIds are common concepts that are reused through Azure to associate different resources that are used together.

In the variables section of the template add the following code:

```json
    "virtualNetworkName": "virtualNetwork",
    "subnet1Name": "subnet-1",
    "nicName": "networkCard",
    "subnetId": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('virtualNetworkName'), variables('subnet1Name'))]"
```

## Add VM to the Virtual Network

A virtual machine is accessible through a virtual network.  The virtual machine's network card can be attached to the virtual network using resourceIds.  Complete the steps below to add the virtual machine to the virtual network:

- Press CTRL+F in VS Code to open the search box
- search for the subnet property of the network card, enter "subnet": (including punctuation) in the search box to find the subnet property
- Change the id property of the subnet to reference the variable defined for the subnetId:

```json
     "subnet": {
        "id": "[variables('subnetId')]"
      }
```

## View Dependencies

The first lab mentioned dependencies to ensure resources are deployed in the correct order.  Note that our template has dependencies to ensure the virtual network is deployed before the virtual machine, since the virtual machine needs to be placed into the virtual network.  Open the search box (CTRL+F) and search for "dependsOn" to see how this is represented in the template.

## Create Parameters

Parameters can be used to make a template more flexible and reusable for multiple users and scenarios.  A simple example is using different credentials for any virtual machine that's created, i.e. the username and password used to log into the virtual machine.  

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
- After completion VS Code will show you a list of parameters to choose from, select adminUsername
- Follow the same steps to update the adminPassword property to use the parameter defined for the password

### Use the Location Parameter

A parameter for the location of resources was also defined.  The virtual machine and network card already use this parameter, but the Virtual NetworkWe defined does not.  Update the location property on the virtual network to use the location parameter.

## Deploy the Template

> # TODO: to simplify use of the problem window (no confusion from other samples) should we open just the template folder???

Before deploying the template, use VS Code to inspect your template for errors.  Format the code if necessary using SHIFT+ALT+F in VS Code.  Then in your command window, verify that your current directory is set to the directory used for this lab before running the following commands.

> **NOTE:**  When deploying the template, you will see a prompt for any parameter vaules that are not provided, for this lab, provide the same values each time you deploy.

PowerShell

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-03-000000 -TemplateFile azuredeploy.json -Verbose
```

Azure CLI

```bash
az group deployment create --resource-group IoC-03-000000 --template-file azuredeploy.json --verbose
```

After the deployment completes, or while the deployment is in process, you can open the Azure Portal and see the resources deployed into your resource group.

## Congratulations

This is the end of this section of the lab.  To see a finished solution, see the final.json file in this folder.
