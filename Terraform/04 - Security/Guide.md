# Security

In this section you will:

- Create secret in an existing Key Vault
- Reference secret in configuration 

## Overview

In any real world Infrastructure as Code project, you will have secrets such as tokens, passwords, connection strings, certificats, encryption keys, etc. that are required in order to provision the desired resources. Although these are required by the code, you should NOT include the actual secret in the code. There are a number of ways to reference secrets from code of varying ease of use and security. In this lab, we will be using a central store, [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/?&ef_id=EAIaIQobChMIocnT3-Cj5QIVbx6tBh16xwXkEAAYASAAEgI-jfD_BwE:G:s&OCID=AID2000128_SEM_IMHcwqu6&MarinID=IMHcwqu6_359393301283_azure%20key%20vault_e_c__73271632300_kwd-415940116485&lnkd=Google_Azure_Brand&gclid=EAIaIQobChMIocnT3-Cj5QIVbx6tBh16xwXkEAAYASAAEgI-jfD_BwE), to store, manage and reference your secrets.

This lab consists of two parts: 
- In part 1, you will creat a secret that will be stored in Azure Key Vault. Although you will be performing and authenticating both of these actions as a single lab user, in the real world, the secrets could and typically would be created and stored by a separate user who would grant the end user or process permission to a given secret. 
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
    - [Azure resourece group](https://www.terraform.io/docs/providers/azurerm/d/resource_group.html): This is the same resource group where you will be provisioning the resources. Instead of adding the string name in here use a variable named `rg`. 
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

        tenant_id = azuread_user.lab04-user.tenant_id
        object_id = azuread_user.lab04-user.object_id

        secret_permissions = [
            "list", "get", "delete", "set"
        ]
    }
    ```


3. Create random password using the Random Provider. Use the `random_password` resource to create a secret that contains special characters and is 24 charters long.
    > **NOTE**: You are using the `random_password` instead of the `random_string` resource to ensure that the generated password is not output in clear text to logs, etc. It will still be stored in the state file which is why it is critical to properly secure your terraform state. 

4. Finally, store secret in Key Vault using the `azurerm_key_vault_secret` resource. Use a variable named `secretId` for the secret name and refer to the output of the random password generated by the previous step using the `result` attribute of the resource. For example, if you had named your random password "admin_pwd", you reference it with `random_password.admin_pwd.result`.

Now that your configuration is completed, let us move on to definining the variables and assigning them values.

### Variables

### Providers 




Update your providers.tf file 

## Part 2 - Use Secret



