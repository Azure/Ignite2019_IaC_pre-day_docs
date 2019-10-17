# Variables

In this section you will:

- Create a network security group
- Create a Network Interface Card (NIC)
- Create a Virtual Machine

## Overview

Apart from provisioning a network interface card as well as a virtual machine, you will modify the playbook you created in previous lab to work with variables.

## Adding variables to your playbook

Modify your playbook created in previous lab to replace hard-coded values as variables.

* Define variables directly inline. By adding `vars:` in the header.

```yaml
- hosts: localhost
  vars:
    myResource_group: myResource_group
    myVNet: myVNet
    mySubNet: "{{ myVnet }}Subnet"
  tasks:
  - name: ...
    ...
  - name: ...
    ...
```

1. Replace hard coded values in your playbook with `"{{ variable_name }}"`. e.g., replace myResource_group with `"{{ myResource_group }}"`
1. You can assign the value for a variable by adding prefix or suffix to another variable. e.g,. " {{ myVnet }}Subnet"
1. Save and run your playbook in Cloud Shell.
1. No change is made since you didn't modify any of the Azure resources.

**Note**:

- to get value from environment variable, do  `"{{ lookup('env', 'AZURE_CLIENT_ID') }}"`

## Create a public IP address

Public IP addresses allow Internet resources to communicate inbound to Azure resources.

1. Add a new variable called `myPublicIP` to your playbook
1. Use the [azure_rm_publicipaddres](https://docs.ansible.com/ansible/latest/modules/azure_rm_publicipaddress_module.html) to create a Public IP Address.
1. Run your playbook.

## Create a Network Interface Card (NIC)

A network interface enables an Azure Virtual Machine to communicate with internet, Azure, and on-premises resources.

1. Add to your existing playbook a variable call `myNIC`.
2. Use the [azure_rm_networkinterface](https://docs.ansible.com/ansible/latest/modules/azure_rm_networkinterface_module.html) to complete this step.
3. Run your playbook.

You can now see `myNIC` in your resource group.

## Create a virtual machine

1. Add to your existing playbook a variable call `myVM`.
2. Use the [azure_rm_virtualmachine](https://docs.ansible.com/ansible/latest/modules/azure_rm_virtualmachine_module.html) to complete this step.
3. Run your playbook.

You can go to [Azure portal](https://portal.azure.com) to verify that you have created the resources.

> **_NOTE:_**  You can refer to [lab2.yml](lab2.yml) for a complete sample playbook.

## Registering variables

The value of a task being executed in Ansible can be saved in a variable and used later.

For example:

```yml
- hosts: web_servers

  tasks:

     - shell: /usr/bin/foo
       register: foo_result
       ignore_errors: True

     - shell: /usr/bin/bar
       when: foo_result.rc == 5
```

This [playbook sample](https://github.com/Azure-Samples/ansible-playbooks/blob/master/rest/resourcegroup_dump_resources.yml) is a good walk-through to see how you can perform a complete dump of resources using the [azure_resource_facts](https://docs.ansible.com/ansible/latest/modules/azure_rm_resource_facts_module.html) module.

## Additional useful resources

- you can assign values to variables defined in playbooks when you run your playbook by doing so:

```bash
ansible-playbook xxx.yml -e "resource_group_name=xxxxxxxxx"
```

- you can also define variables in a included files. Use the `vars_files` keyword and modify your playbook by like so:

```yaml
- hosts: localhost
  vars_files:
    - ./vars.yml
  tasks:
  - name: ...
    ...
  - name: ...
    ...
```

Move all the variables to a file called vars.yml. In this example, vars.yml is found in the same directory as the playbook:

```yaml
myResource_group: myResource_group
myVNet: myVNet
mySubNet: "{{ myVnet }}Subnet"
```

> If you move all variables to a vars.yml file, you will need to explicitly upload the file to Cloud Shell. 
> - right clicking vars.yml and select **"Upload to Cloud Shell"**.
> - in Cloud Shell terminal, move the file to ./clouddrive/ansible-playbooks/ by doing `mv vars.yml ./clouddrive/ansible-playbooks/`

- Refer to [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html) for more details and ways to use variables.