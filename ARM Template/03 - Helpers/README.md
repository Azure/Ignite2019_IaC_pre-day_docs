# LAB 3 - Azure Resource Manager Templates

## Add a Network Security Group to the Template

add vm

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

nsg name

```json

"variables": {
  "nsgName": "nsg",
```

```json

{
  "type": "Microsoft.Network/networkSecurityGroups",
  "apiVersion": "2018-04-01",
  "name": "[variables('nsgName')]",


```

## Assign the Netword Security Group

place it on the nic or the subnet - if we place it on the nic only one vm is protected, so put it on the subnet

## Deploy the Template

without the loop

## Create a copy loop for multiple security rules

Add parameter array w/ defaultValue
edit the nsg to have the copy loop

## Deploy the Template with the Copy Loop

```json
    {
      "type": "Microsoft.Network/virtualNetworks",

```

## Go to the Azure Portal

Examing the multiple security rules

