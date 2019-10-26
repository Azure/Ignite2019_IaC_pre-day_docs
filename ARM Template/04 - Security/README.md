# LAB 4 - Azure Resource Manager Templates

## Add a Parameters File and Parameters

```json

    "adminUsername": {
        "value": "ignite"
    },
    "adminPasswordOrKey": {
        "value": "Ignite!2019"
    }


```

## Deploy with a Parameter File

## Delete the Resource Group

## Use KeyVault to store the Admin Password

## Create KeyVault and Add a Secret

Set the properties on the vault for template deployment (access policy???)

## Upate Parameter File to Use KeyVault

Get the resourceId of the keyvault using Portal/PowerShell

```json
    "reference": {
      "keyVault": {
       "id": "/subscriptions/XXXXXXX/resourceGroups/resourceGroupName/providers/Microsoft.KeyVault/vaults/vaultName"
      },
      "secretName": "secretName"
   }
```


## Deploy the Template


