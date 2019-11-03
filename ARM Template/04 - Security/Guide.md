# ARM Templates - LAB 4

To begin this lab, start with the template from the previous lab or use the azuredeploy.json file provided in this folder.

> **NOTE:** Open the 04-Security folder for this lab

## Add a Parameters File and Parameters

When deploying templates you have the option to use a parameter file to supply parameters to the deployment.  This removes the prompt for these vaules at deployment time.  Open the **azuredeploy.parameters.json** file and add the following code to the "parameters" object:

```json
    "adminUsername": {
        "value": "ignite"
    },
    "adminPassword": {
        "value": "Ignite!2019"
    }
```

> **NOTE:**  Change the values above to match the username and password you have been using for previous deployments.

Format the code using SHIFT+ALT+F if needed and save the file.

## Deploy with a Parameter File

Verify that your current directory is set to the directory used for this lab before running the following commands.

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

***Note that in this deployment there was no prompt for the adminUserName and adminPassword as those parameter values were provided by the parameters file.***

## Use KeyVault to store the Admin Password

Saving a password or other secret in a parameter file makes it easy to test a template but is an unsecure pattern when used in practice.  Template deployments can use Azure KeyVault to secure secrets so that only the person or principal deploying the template can access that secret.  The secret can then be referenced directly from KeyVault during deployment avoiding the need to put the secret directly in the parameters file.

### Add a Secret to KeyVault

Use the steps below to add a secret to the KeyVault available for the lab:

- Open the Azure Portal and go to the IoC-01-000000 resource group created for your account (note that the suffix 000000 will be different for each user)
- Open the KeyVault created for the lab
- Select the Secrets tab and click Generate/Import to add a secret
- Specify a name for the secret for example: "adminPassword"
- Add the value for the secret
- Click "Create" to save the secret in KeyVault

### Upate Parameter File to Use KeyVault

Next, update the parameter file to reference the newly created secret.  Copy the code below and replace the adminPassword parameter in the azuredeploy.parameter.json file.

```json
    "adminPassword": {
        "reference": {
          "keyVault": {
            "id": "/subscriptions/XXXXXXX/resourceGroups/XXXXXXXX/providers/Microsoft.KeyVault/vaults/XXXXXXXX"
        },
        "secretName": "adminPassword"
      }
   }
```

Next, follow the steps below to update the resourceId to identify the KeyVault for your account:

- In the Azure Portal select the Properties tab for the Azure KeyVault
- Find the resourceId in the Properties window, and click the copy icon
- Paste the resourceId from the clipboard to replace the placeholder id in azuredeploy.paramaters.json
- Save the changes to the parameters file

## Deploy the Template

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

## Congratulations

This is the end of this section of the lab.  To see a finished solution, see the final.json file in this folder.
