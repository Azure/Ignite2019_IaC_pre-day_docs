# ARM Templates - LAB 3

To begin this lab, start with the template from the previous lab or use the azuredeploy.json file provided in this folder.

> **NOTE:** Open the 03-Helpers folder for this lab

## Add a Network Security Group to the Template

Next, add a Network Security Group to the template to help secure the resources deployed in the template.  Copy and paste the code below at the top of the resources section of the template.

```json
    {
      "type": "Microsoft.Network/networkSecurityGroups",
      "apiVersion": "2019-06-01",
      "name": "nsg",
      "location": "[parameters('location')]",
      "properties": {
        "securityRules": [
          {
            "name": "default-allow-22",
            "properties": {
              "priority": 1000,
              "sourceAddressPrefix": "*",
              "protocol": "Tcp",
              "destinationPortRange": "22",
              "access": "Allow",
              "direction": "Inbound",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*"
           }
          }
        ]
      }
    },
```

## Create Variables

Add the following variable for the variable for the name of the network security group to the top of the variables section of the template.

```json
    "nsgName": "nsg",
```

Update the name property of the network security group to use the defined variable.

```json
  "name": "[variables('nsgName')]",
```

## Assign the Network Security Group to a Subnet

The security group must be assigned to a sbunet or network card.  Placing the security group on a subnet will secure all resources in that subnet. Find the subnet named "subnet-1" in the template.  Copy and paste the following code inside, and at the top of, the properties object of the subnet resource defintion - above the addressPrefix:

```json
            "networkSecurityGroup": {
              "id": "[resourceId('Microsoft.Network/networkSecurityGroups', variables('nsgName'))]"
            },
```

### DependsOn

Since the subnet requires the network security group, add a dependency between the two resources to ensure the security group is deployed first.  Add the following code to the top of the dependsOn property for the virtualNetwork.  Copy the following code and paste below the location property for the virtualNetwork resource.

```json
      "dependsOn": [
        "[variables('nsgName')]"
      ],

```

Note that the dependsOn property requires a resourceId of a resource defined in the template.  If the resource name is unique, you can simply use the resource name instead of the full resourceId.

## Examine Changes Before Deployment

> *At this conference ARM will introduce the private preview of a new feature for ARM Templates currently named "WhatIf".  This feature will show the changes that will be applied when a template is deployed so you can examine those changes before deployment begins.  This section of the lab will give you a preview of the feature. If you are interested in participating in the preview you can sign up at https://aka.ms/whatifpreview*

Before deploying the template, run the following command to preview the changes that will be applied when the template is deployed. Note, this command is currently only available in PowerShell.  If you have not use PowerShell for the earlier sections of the lab, you will need to log in first.

Format the code (SHIFT+ALT+F), inspect your template for errors and save the file.  Then in your command window, verify that your current directory is set to the directory used for this lab before running the following commands.

> **NOTE:** Set the current directory to the 03-Helpers folder for this lab

```PowerShell
Connect-AzAccount
```

After login, run the following command:

```PowerShell
New-AzResourceGroupDeploymentWhatif -ResourceGroupName IoC-02-000000 -TemplateUri azuredeploy.json
```

When the command finishes you will see the output of the command showing that a Network Security Group will be added as a result of this deployment.

> **NOTE:** If you see an error running the WhatIf command or have closed your PowerShell window since the first section, open a new PowerShell window and import the whatif modules.

## Deploy the Template

Before deploying the template, format the code (SHIFT+ALT+F) and VS Code to inspect your template for errors.  Then in your command window, verify that your current directory is set to the directory used for this lab before running the following commands.

> **NOTE:** Set the current directory to the 03-Helpers folder for this lab

PowerShell

```PowerShell
New-AzResourceGroupDeployment -ResourceGroupName IoC-02-000000 -TemplateFile azuredeploy.json -Verbose
```

Azure CLI

```bash
az group deployment create --resource-group IoC-02-000000 --template-file azuredeploy.json --verbose
```

After the deployment completes, or while the deployment is in process, you can open the Azure Portal and see the resources deployed into your resource group.

## Create a Copy Loop for Multiple Security Rules

Network Security Groups can contain multiple rules.  The rules can be defined individually by repeating the definition for a rule.  The code may look like the following.

```json
      "securityRules": [
        {
          "name": "default-allow-22",
          "properties": {
            "priority": 1000,
            "sourceAddressPrefix": "*",
            "protocol": "Tcp",
            "destinationPortRange": "22",
            "access": "Allow",
            "direction": "Inbound",
            "sourcePortRange": "*",
            "destinationAddressPrefix": "*"
          }
        },
        {
          "name": "default-allow-80",
          "properties": {
            "priority": 1001,
            "sourceAddressPrefix": "*",
            "protocol": "Tcp",
            "destinationPortRange": "80",
            "access": "Allow",
            "direction": "Inbound",
            "sourcePortRange": "*",
            "destinationAddressPrefix": "*"
          }
        },
        {
          "name": "default-allow-443",
          "properties": {
            "priority": 1002,
            "sourceAddressPrefix": "*",
            "protocol": "Tcp",
            "destinationPortRange": "443",
            "access": "Allow",
            "direction": "Inbound",
            "sourcePortRange": "*",
            "destinationAddressPrefix": "*"
          }
        }
      ]

```

You can see that this approach is verbose because some of the code is duplicated which makes it harder to maintain.  Copy loops can be used a number of ways in a template to reduce the duplication.  Next, we'll modify the template to create a copy loop for the security rules.

### Add Parameter for the Rules

To make the template more flexible, define a parameter to determine which ports will be available through the security group.  The parameter will contain an array of ports. Add the following code to the top of the parameters section of the template.

```json
    "nsgRules": {
      "type": "array",
      "defaultValue": [
        22, 80, 443
      ]
    },
```

### Modify the Network Security Group Definition

Next add the following code to the top of the properties object on the network security group resource definition, just above the securityRules.

```json
        "copy": [
          {
            "name": "securityRules",
            "count": "[length(parameters('nsgRules'))]",
            "input": { }
          }
        ],
```

This will create a copy loop for the property indicated by the name property of the copy loop - in this case the securityRules property.  The number of rules is determine by the count property, which in this case is determined by the size or length of the array parameter for the nsgRules.

Next, cut the content of the existing securityRules property and paste it inside the "input" property in the copy loop.  Start at the "name" property and include everything up to and including the "destinationAddressPrefix" property - also include the closing }.  Here, we are simply moving the defintion from outside of the copy loop to inside the input property of the copy loop.  After that, remove the empty "securityRules" property. The code should now look like the following (format the code if needed):

```json
        "copy": [
          {
            "name": "securityRules",
            "count": "[length(parameters('nsgRules'))]",
            "input": {
              "name": "default-allow-22",
              "properties": {
                "priority": 1000,
                "sourceAddressPrefix": "*",
                "protocol": "Tcp",
                "destinationPortRange": "22",
                "access": "Allow",
                "direction": "Inbound",
                "sourcePortRange": "*",
                "destinationAddressPrefix": "*"
              }
            }
          }
        ]
```

As written, our code would now create 3 identical copies of a securityRule.  We need to change the property values to create the rules according to the parameter values passed in to the template.

First we need to change the name of the securityRule which is determined by the name property in the input section of the copy loop. We will dynamically create the name based on the values in the array.  Change the name property to use the following value:

> **NOTE:** Be sure to change the name property inside the input object of the copy loop, not the name of the copy loop itself.

```json
            "name": "[concat('allow-', parameters('nsgRules')[copyIndex('securityRules')])]",
```

This will create a name that starts with the text "allow-" and is appended with the port used in the rule.

Next, give the rule a unique priority based on the order of the ports in the array.  Change the "priority" property value to increment the priority of each successive rule:

```json
                "priority": "[add(1000, copyIndex('securityRules'))]",
```

The copyIndex function returns a integer for the index of the loop so the expression will evaluate to 1000, 1001, 1002, etc.

Finally, set the "destinationPortRange" to the value of each paramter value.

```json
                "destinationPortRange": "[parameters('nsgRules')[copyIndex('securityRules')]]",
```

This simply references the array value using the copyIndex() function.

### Verify Changes

After editing the template you should have the folloing copy loop in the properties object and nothing else.

```json
        "copy": [
          {
            "name": "securityRules",
            "count": "[length(parameters('nsgRules'))]",
            "input": {
              "name": "[concat('allow-', parameters('nsgRules')[copyIndex ('securityRules')])]",
              "properties": {
                "priority": "[add(1000, copyIndex('securityRules'))]",
                "sourceAddressPrefix": "*",
                "protocol": "Tcp",
                "destinationPortRange": "[parameters('nsgRules')[copyIndex('securityRules')]]",
                "access": "Allow",
                "direction": "Inbound",
                "sourcePortRange": "*",
                "destinationAddressPrefix": "*"
              }
            }
          }
        ]
```

## Deploy the Template with the Copy Loop

Before deploying the template, use VS Code to inspect your template for errors.  Format the code if necessary using SHIFT+ALT+F in VS Code.  Then in your command window, verify that your current directory is set to the directory used for this lab before running the following commands.

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
