# LAB 5 - Azure Resource Manager Templates

## Copy the Template

copy/paste the template file, call the new file vm.json

## Modify the vm.json Template


### Remove Networking from vm.json

Remove the VNet Resource
Remove the NSG resource
Remove the variables for the VNet and NSG
Remove unused parameter for the NSG (use VS Code to identify)
Remove dependsOn from the nic

### Add Parameters

Add a parameter for the subnetId and change the variable reference to a parameter reference
Add a vm name parameter since we re-use this template and don't want all VMs to have the same name
Update the VM resource

## Remove the VM Resource from azuredeploy.json

Remove the NIC
Remove the VM
Remove the nicName variable (leave the others we'll use those)

## Add a Deployment for the VM to azuredeploy.json

```json



```

## Add Parameter Values to the Deployments Resource

```json

```

## Deploy Template to a New/Different Resource Group

## Bonus - Add Copy Loop To Deploy Multiple VMs
