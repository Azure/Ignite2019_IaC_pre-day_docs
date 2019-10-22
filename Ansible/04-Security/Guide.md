# Security

**Security should be the first or one of the first thing you consider. Not in step(Lab) #4.**

In this section you will:

- Create a secret in an existing Azure Key Vault.
- Modify your playbook so that you reference the secret in your playbook.

## Add a secret to Azure Key Vault

Azure Key Vault is a tool for securely storing and accessing secrets.

1. Use [azure_rm_keyvault](https://docs.ansible.com/ansible/latest/modules/azure_rm_keyvault_module.html) to create an Azure Key Vault. For the purpose of this lab, we have pre-provisioned an Azure Key Vault for each lab participant.
1. Use [azure_rm_keyvaultsecret](https://docs.ansible.com/ansible/latest/modules/azure_rm_keyvaultsecret_module.html) to add a secret. 

## Retrieve secret from Azure Key Vault

While preparing for this workshop, we discovered we do not have a module for retrieving secret from Azure Key Vault.

We will be adding a new module called azure_rm_keyvaultsecret_info in future release. For the purpose of this lab, we will embed the new module using the `roles` keyword. (Roles will be explained in Lab 5.)

1. Copy `azure_rm_keyvaultsecret_info.py` in `modules/library`(/modules/library) to `clouddrive/ansible-playbooks/modules/library`
2. Use azure_rm_keyvaultsecret_info to get secret you added in previous step. Here are a couple of examples on how to you can get secret.

```yml

  - name: Get latest version of a secret
    azure_rm_keyvaultsecret_info::
      vault_uri: "https://myVault.vault.azure.net"
      name: mysecret

  - name: Get a specific version of a secret
    azure_rm_keyvaultsecret_info:
      vault_uri: "https://myVault.vault.azure.net"
      name: mysecret
      version: 12345
```

> **_NOTE:_** You can refer to [lab4-keyvault.yml](lab4-keyvault.yml) for a complete sample playbook.  

## Replace hard coded password in previous lab

Next, instead of hard coding the password when provisioning VM, you can now:
1. Run a task to get retrieve the secret from Azure Key Vault. Hint: use `register output`.
2. Use the value retrieved back from key vault to configure the admin password for the VM. Hint: use `output.secret.value`

> **_NOTE:_** You can refer to [lab4.yml](lab4.yml) for a complete sample playbook.  


## Additional useful resources

This [sample playbook](https://github.com/Azure-Samples/ansible-playbooks/blob/master/keyvault_create.yml) for a good walk-through of creating an Azure Key Vault.



