# Security

In this section you will:

- Create secret in an existing Key Vault
- Reference secret in configuration 

## Overview

In any real world Infrastructure as Code project, you will have secrets such as tokens, passwords, connection strings, certificates, encryption keys, etc. that are required in order to provision the desired resources. Although these are required by the code, you should NOT include the actual secret in the code. There are a number of ways to reference secrets from code of varying ease of use and security. In this lab, we will be using a central store, [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/?&ef_id=EAIaIQobChMIocnT3-Cj5QIVbx6tBh16xwXkEAAYASAAEgI-jfD_BwE:G:s&OCID=AID2000128_SEM_IMHcwqu6&MarinID=IMHcwqu6_359393301283_azure%20key%20vault_e_c__73271632300_kwd-415940116485&lnkd=Google_Azure_Brand&gclid=EAIaIQobChMIocnT3-Cj5QIVbx6tBh16xwXkEAAYASAAEgI-jfD_BwE), to store, manage and reference your secrets.

This lab consists of two parts: 
- In part 1, you will create a secret that will be stored in Azure Key Vault. Although you will be performing and authenticating both of these actions as a single lab user, in the real world, the secrets could and typically would be created and stored by a separate user who would grant the end user or process permission to a given secret. 
- In part 2, you will reference and use the secret stored in Azure Key Vault in your configuration. Referencing secrets in this manner will ensure that the secret is not exposed in code but also allows the secret to be changed / rotated without changing your code. 

## Part 1 - Store Secret in Azure Key Vault

In order to create the secret in a secure manner, you will be introduced to the concept of using multple Terraform providers in a single configuration. You will add the following providers to our configuration:
 - [Azure Active Directory Provider](https://www.terraform.io/docs/providers/azuread/index.html)
 - [Random Provider](https://www.terraform.io/docs/providers/random/index.html)

### Setup

Before digging into the configuration, lets get the environment set up by create a folder in cloudshell for your code for this part of the lab. Name it something like "lab04-part1" then create the following 4 files in this new folder:
- providers.tf
- main.tf
- terraform.tfvars
- variables.tf

By this point, these files should look familiar.

### Configuration

Now lets dig into the configuration (main.tf). 
1. Start by reference existing Azure resources using [Terraform data sources](https://www.terraform.io/docs/configuration/data-sources.html) that are required by other resources that you will be using in your configuration as follows:
    - [Azure resource group](https://www.terraform.io/docs/providers/azurerm/d/resource_group.html): This is the Key Vault resource group, "first resource group" from Environment Details tab in the lab, It is NOT the same resource group where you will be provisioning the resources. Instead of adding the string name in here use a variable named `rg`. 
        > **NOTE**: We will define the value of this and other variables later in this lab.  
    - [Active Directory user](https://www.terraform.io/docs/providers/azuread/d/users.html): This data source will be used to get the Active Directory id for your lab user in order to assign the appropriate Azure Key Vault permissions. Use a variable named `labUser` for the `user_principle_name`.
    - [Azure Key Vault instance](https://www.terraform.io/docs/providers/azurerm/d/key_vault.html): As I am sure you have already noticed, your lab environment has a pre-provisioned Key Vault instance. This data source will be used to reference the Key Vault instance in the `azurerm_key_vault_secret` and `azurerm_key_vault_access_policy` resources discussed later. Use a variable named `keyVault` for the Key Vault name.
        > **NOTE**: Key Vault can be provisioned with Terraform but to save time and focus on the key concepts for the lab, we have pre-provisioned it for you. 

2. Grant your lab user access to create and read Azure Key Vault secrets. In order to accomplish this you will use the `azurerm_key_vault_access_policy` resource.
    > **NOTE**: Although this is not required for this lab since your lab account already has access, this will be required in a typical scenario where a different user is storing the secret from the user who is using the secret.

    In this resource you will reference the id from the Azure Key Vault data source and properties from the Azure Active Directory user data source as follows:

    ```Terraform
    resource "azurerm_key_vault_access_policy" "lab04" {
        key_vault_id = azurerm_key_vault.lab04.id

        tenant_id = var.tenantId
        object_id = data.azuread_user.lab04-user.id

        secret_permissions = [
            "list", "get", "delete", "set"
        ]
    }
    ```


3. Create random password using the Random Provider. Use the `random_password` resource to create a secret that contains special characters and is 24 charters long.
    > **NOTE**: You are using the `random_password` instead of the `random_string` resource to ensure that the generated password is not output in clear text to logs, etc. It will still be stored in the state file which is why it is critical to properly secure your terraform state. 

4. Finally, store secret in Key Vault using the `azurerm_key_vault_secret` resource. Use a variable named `secretId` for the secret name and refer to the output of the random password generated by the previous step using the `result` attribute of the resource. For example, if you had named your random password "admin_pwd", you reference it with `random_password.admin_pwd.result`.

Now that your configuration is completed, let us move on to definining the variables and assigning them values.

#### CHEAT SHEET
<details>
<summary>
Expand for full main.tf code
</summary>

```terraform
data "azurerm_resource_group" "lab04" {
  name = var.rg
}

data "azuread_user" "lab04-user" {
  user_principal_name = var.labUser
}

data "azurerm_key_vault" "lab04" {
  name                = var.keyVault
  resource_group_name = data.azurerm_resource_group.lab04.name
}

resource "random_password" "admin_pwd" {
  length = 24
  special = true
}

resource "azurerm_key_vault_access_policy" "lab04" {
  key_vault_id = data.azurerm_key_vault.lab04.id

  tenant_id = var.tenantId
  object_id = data.azuread_user.lab04-user.id

  secret_permissions = [
    "list", "get", "delete", "set"
  ]
}

resource "azurerm_key_vault_secret" "lab04" {
  name         = var.secretId
  value        = random_password.admin_pwd.result
  key_vault_id = data.azurerm_key_vault.lab04.id
}
```

</details>

### Variables

In this part of the lab we will be editing two files: variables.tf and terraform.tfvars. Let's start by defining and describing the variables that will be used in our configuration. We will do this in the variables.tf file. 

Although having a separate file where variables are defined is not required, it is a common practice that makes it easier to find, add and change them. In this file you will be using [variable blocks](https://www.terraform.io/docs/configuration/variables.html) for each Terraform variable required by your configuration. 

Add the following Terraform variables to the file:
- rg
- secretId
- labUser
- tenantId
- keyVault

Ensure that you define a type and description for each variable. Although these are not required, it is another best practice that will make using your Terraform coniguration easer for you and your teammates.

Now that the variables are defined, you need to give them values. As you have learned in previousl labs for values that are not secrets, add the values to your terraform.tfvars file so that they will be discovered and used when Terraform is run. 

Add the appropriate string values for your lab environment for all of the variables that were just defined in your variables.tf file. For secretId use the string "`lab04admin`". For tenantId run the following command in the Azure Cloud Shell:
```bash
az account show --query "tenantId"
```

> **NOTE**: You should get the exact resource group name, lab user name and key vault name to use for your variable values from the *Environment Details* tab in your lab.

#### CHEAT SHEETS
<details>
<summary>
Expand for full variables.tf code
</summary>

```terraform
variable "rg" {
  type        = "string"
  description = "Name of Lab resource group to provision resources to."
}

variable "secretId" {
  type        = "string"
  description = "name of secret containing admin password for vms"
}

variable "labUser" {
  type        = "string"
  description = "Username for lab account"
}

variable "tenantId" {
  type        = "string"
  description = "Id for tenant"
}

variable "keyVault" {
  type        = "string"
  description = "Name of the pre-existing key vault instance"
}
```

</details>

<details>
<summary>
Expand for full terraform.tfvars code
</summary>

```terraform
rg = "" ## Enter the resource group pre-created in your lab
secretId = "lab04admin"
labUser = "" ## Enter the lab user name as shown in the Environment Details tab
keyVault = "" ## Enter the name of the pre-created key vault instance
tenantId = "" ## Enter the tenant ID for your lab user
```

</details>


### Providers 

The fourth and final file that we need to update for this part of the lab is the providers.tf file. As you have seen in previous labs, you will utilize the [providers block](https://www.terraform.io/docs/configuration/providers.html) to set the version of the providers that are required for this configuration. Add a block for the following providers that are used in the config:
- `azurerm` greater than or equal to version 1.35
- `azured` greater than or equal to version 0.6.0
- `random` greater than or equal to version 2.2.0

#### CHEAT SHEET

<details>
<summary>
Expand for full providers.tf code
</summary>

```terraform
provider "azurerm" {
  version = "~>1.35.0"
}

provider "azuread" {
  version = "~>0.6.0"
}


provider "random" {
  version = "~>2.2.0"
}
```
</details>

### Apply the configuration

With the Terrform configuration complete, all that is left to do is to validate that everything is correct, validate that it is going to do what you expect and apply it. As you have learned from the previous 3 labs execute the following steps:
- Initiallize the working directory
- Create the execution plan
- Apply the changes

#### CHEAT SHEET

<details>
<summary>
Expand for exact commands to run
</summary>

```bash
terraform init
...
terraform plan -out tfplan
...
terraform apply tfplan
...
```
</details>

### Verification

Assuming that the configuration completed successfully, you can validate that everything really did do as you expect by browsing to the resource group where you provisioned the resources, then select the Key Vault instance and ensure that the "lab04admin" secret has been created.

>**CODE:** To view all of the completed code for this part of the lab go [here](Code%20-%20Part%201/).

## Part 2 - Use Secret

In this part of the lab you will use the secret that you just created to replace the password for your virtual machine. To do this we will be editing three of the files from the previous lab: variables.tf, terrafrom.tfvars, vm.tf.

Lets start by adding the variable that you will need to reference the secret from your virtual machine resource. Add two new variables with the following names and values:
- `secretId`= "lab04admin"
- `keyVault` = "{{ The name of your Key Vault instance }}"


Now with the required variables defined, you will update the vm.tf configuration file to accomplish the following tasks:

1. Create a reference to the Azure Key Vault instance that contains the secret. 
1. Create a reference to the Azure Key Vault Secret. 
1. Replace the password string containing the vm admin password with a reference to the secret. 

Add Terraform data sources for the first two tasks using the [azurerm_key_vault](azurerm_key_vault) and [azurerm_key_vault_secret](azurerm_key_vault_secret).

For the third task, simply replace the string that is assigned to the value of the `admin_password` property of the `os_profile` in the `azurerm_virtual_machine` resource with a reference to the secret value as follows:

```terraform
...
os_profile {
  computer_name  = "hostname"
  admin_username = "testadmin"
  admin_password = data.azurerm_key_vault_secret.tf_pre-day.value
}
...
```

The admin password is not a tracked property in the azurerm_virtual_machine resource so the changes that you have made will result in a plan that requires no changes, additions or deletions. To force the change, we will [taint](https://www.terraform.io/docs/commands/taint.html) the state for the VM resource. This will force Terraform destroy and recreate the resource. 

>**NOTE** The above behavior is a result of older functionality of the underlying APIs and is something that will change in the next major release of azurerm provider [version 2.0](https://www.terraform.io/docs/providers/azurerm/guides/2.0-upgrade-guide.html).

In Cloud Shell run the following command:

```terraform
terraform taint azurerm_virtual_machine.tf_pre-day
```

Finally, as you have done in previous sections and labs:
- Povision the new infrasctructure using Terraform plan and apply
- Validate that everything was provisioned as expected.

Congratulations, you have securely provisioned your infrastructure!

#### CHEAT SHEETS

<details>
<summary>
Expand for full terraform.tfvars code
</summary>

```terraform
rg = "" ## Enter the resource group pre-created in your lab
location = "" ## Enter the azure region for your resources
secretId = "lab04admin"
keyVault = "" ## Enter the name of the pre-created key vault instance
rg2 = "" ## Enter the name of the resource group where key vault exists
tags = {
    event           = "Ignite"
    year            = "2019"
    session_id      = "PRE04"
    iac_tool        = "terraform"
    lab             = "4"
}
```
</details>

<details>
<summary>
Expand for full variables.tf code
</summary>

```terraform
variable "rg" {
  type        = "string"
  description = "Name of Lab resource group to provision resources to."
}

variable "rg2" {
  type        = "string"
  description = "Name of Lab resource group where key vault exists."
}

variable "location" {
  type        = "string"
  description = "Azure region to put resources in"
}

variable "secretId" {
  type        = "string"
  description = "name of secret containing admin password for vms"
}

variable "keyVault" {
  type        = "string"
  description = "Name of the pre-existing key vault instance"
}

variable "tags" {
  type        = map(string)
  description = "tags to be used with all resources in the lab"
}
```
</details>

<details>
<summary>
Expand for full vm.tf code
</summary>

```terraform
# Data source reference to key vault instance
data "azurerm_key_vault" "tf_pre-day" {
  name                = var.keyVault
  resource_group_name = var.rg2
}

# Data source reference to the secret
data "azurerm_key_vault_secret" "tf_pre-day" {
  name         = var.secretId
  key_vault_id = data.azurerm_key_vault.tf_pre-day.id
}

# Configure Virtual Machine
resource "azurerm_virtual_machine" "tf_pre-day" {
  name                  = "tfignitepredayvm"
  location              = var.location
  resource_group_name   = var.rg
  vm_size               = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.tf_pre-day.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = data.azurerm_key_vault_secret.tf_pre-day.value
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags                = var.tags
}
```
</details>

>**CODE:** To view all of the completed code for this part of the lab go [here](Code%20-%20Part%202/).