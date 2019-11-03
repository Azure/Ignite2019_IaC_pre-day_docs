# ARM Templates - LAB 5

To begin this lab, start with the template from the previous lab or use the azuredeploy.json file provided in this folder.

This lab will walk through the creation of a template that can be reused as a single piece of many complex deployments.  We will separate the networking and virtual machine resources so they can be deployed independently.  A common scenario is that a virutal network will be a shared resource that is deployed infrequently - while virtual machines can be deployed, deleted and redeployed frequently.

> **NOTE:** Open the 05-Reusability folder for this lab

## Copy the Template

- In VS Code, copy/paste the azuredeploy.json template file.  Rename the new file to "my-vm.json".
- Copy/paste the azuredeploy.parameters.json file from the previous lab, into the folder for this lab

## Modify the my-vm.json Template

Next, modify the my-vm.json template to contain only the resources needed to deploy a virtual machine.  This template can then be used in any number of deployments or applications without the need to duplicate the code or concept each time it is used.

### Remove Networking from vm.json

To update the template to contain only the VM resources, complete the following steps:

- Remove the Virtual Network resource - a simple way to do this is to collapse the JSON needed for the resource and delete the {} that remain
- In VS Code, move the mouse next to the line number of the starting { for the virtual network and click the down array that appears
- Next, highlight the collapsed {} and delete them
- Remove the Network Security Group resource
- Remove the variables for the Virtual Network and Network Security Group - the variable for the nicName should be the only remaining variable
- Remove unused parameter for the nsgRules - notice that VS Code will underline this parameter to indicate it is no longer used
- Remove dependsOn property from the networkInterface card since the subnet is no longer defined in this template

### Add Parameters

Next, add some parameters to the my-vm.json template to make it more flexible for a variety of deployments.

- Add a parameter for the subnetId to the parameters section of the template - be sure to add a comma to separate parameter definitions

```json
    "subnetId": {
      "type": "string"
    },
```

- On the subnet reference for the networkInterface card, VS Code will show an error for the subnet variable that was deleted - change "variables" to "parameters"
- Add a parameter for the virtual machine name, since we re-use this template and do not want all VMs to have the same name

```json
    "vmName": {
      "type": "string"
    },
```

- Update the name property on the VM resource to use this new parameter

```json
      "name": "[parameters('vmName')]",
```

- Update the computerName property in the osProfile object to use the vmName parameter as well

- Update the nicName variable so that each VM will have a networkInterface with the same naming pattern as the VM itself

```json
      "nicName": "[concat(parameters('vmName'), '-nic')]",
```

- Save your changes to the my-vm.json file

### Verify the Changes

If you want to see how your changes compare to this section in the lab, you can use VS Code to do the comparison.

- Right-click on the my-vm.json file and choose "Select for Compare"
- Right-click on the vm.json file and choose "Compare with Selected"

Any differences between the files will be highlighted but can be ignored for this section of the lab.

## Remove the VM Resource from azuredeploy.json

Next, remove the VM Resources from the azuredeploy.json file.

- Remove the NetworkInterfaceCard and virtualMachine resources from azuredeploy.json - use VS Code to collapse the resource defintion to make it easier to delete
- Remove the nicName variable

## Add a Deployment for the VM to azuredeploy.json

Next, add a deployment resource to the template.  This resource will be used to deploy the my-vm.json template in conjunction with the virtual network resources defined in azuredeploy.json.  Add the following code to the resources section of the template.

```json
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2019-05-01",
      "name": "create-vm",
      "dependsOn": [
        "[variables('virtualNetworkName')]"
      ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "https://raw.githubusercontent.com/Azure/Ignite2019_IaC_pre-day_docs/master/ARM%20Template/05%20-%20Reusability/vm.json",
          "contentVersion": "1.0.0.0"
        },
        "parameters": {
          "vmName": {
            "value": "linux-vm"
          },
          "adminUsername": {
            "value": "[parameters('adminUsername')]"
          },
          "adminPassword": {
            "value": "[parameters('adminPassword')]"
          },
          "location": {
            "value": "[parameters('location')]"
          },
          "subnetId": {
            "value": "[variables('subnetId')]"
          }
        }
      }
    },
```

Save the azuredeploy.json file.

## Deploy the Template

> **NOTE:** Since you are not able to check code into the github repo used for this lab, the deployment resource will reference the vm.json file already provided instead of the my-vm.json file you created.  You can compare the 2 files to see how you did.

Before deploying the template, use VS Code to inspect your template for errors.  Format the code if necessary using SHIFT+ALT+F in VS Code.  Then in your command window, verify that your current directory is set to the directory used for this lab before running the following commands.  You should see no prompts for parameter values since all values should be in the parameters file.

> **NOTE:** Depending on your version of Azure Powershell the parameter name for the **template parameters file** maybe be either ***TemplateParameters*** or ***TemplateParametersFile***

PowerShell

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-02-000000 -TemplateFile azuredeploy.json -TemplateParameters azuredeploy.parameters.json -Verbose
```

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-02-000000 -TemplateFile azuredeploy.json -TemplateParametersFile azuredeploy.parameters.json -Verbose
```

Azure CLI

```bash
az group deployment create --resource-group IoC-02-000000 --template-file azuredeploy.json --parameters '@azuredeploy.parameters.json' --verbose
```

After the deployment completes, or while the deployment is in process, you can open the Azure Portal and see the resources deployed into your resource group.

## Add Copy Loop To Deploy Multiple VMs

Next, add a copy loop on the deployment resource that deploys the VM.  This will allow the template to create multiple VMs in a single deployment without duplicating the code.

- In the deployments resource, add the following code above the properties object:

```json
      "copy": {
        "name": "vmLoop",
        "count": 3
      },
```

- Create a unique name for each deployment in the copy loop by changing the name property of the deployment resource to the following:

```json
      "name": "[concat('create-vm', copyIndex())]",
```

- In the parameters section of the deployments resource, change the name property to the following:

```json
            "value": "[concat('vm-', copyIndex())]"
```

This loop will create 3 VMs with the names vm-0, vm-1 and vm-2 in the resourceGroup.  Deploy the template to see the results.

## Finish

This is the end of the bonus section of the lab.  To see a finished solution, see the final.json file in this folder.
