# Reusability

In this section you will:

- include a task or list of tasks in your play
- learn how to use Dynamic Inventory
- get an introduction to Ansible roles

## Before you start

You will be working on multiple files and need to upload all of them to Cloud Shell in the right location. It can become cumbersome to continue running your playbook in Cloud Shell.

The VS Code Ansible extension provides better integration experience when you need to work with multiple file. You can hit `F1` to copy files to remote host. 

Hence to continue, we recommend running playbook in remote host from Lab 5 onwards.

## Reusing task(s) in your playbook

You can use the [include](https://docs.ansible.com/ansible/latest/modules/include_module.html) and [include_tasks](https://docs.ansible.com/ansible/latest/modules/include_tasks_module.html#include-tasks-module) modules to dynamically include a task or a list of tasks.

Let's modify what you have done so far to create a multi-tier application. You can use this Azure CLI sample as a guide to create a [network of multi-tier applications](https://docs.microsoft.com/en-us/azure/virtual-network/scripts/virtual-network-cli-sample-multi-tier-application):

- a virtual network with front-end and back-end subnets:
    - Traffic to the front-end subnet is limited to HTTP and SSH
    - Traffic to the back-end subnet is limited to MySQL, port 3306
- two virtual machines, one in each subnet

1. Move all common tasks related to subnet configuration to one YAML file say configurenetwork.yml so that you can use the same list of tasks to provision and configure the subnets.

```yml
- name: Create a subset within the virtual network
  azure_rm_subnet:
    ...
  register: subnet
    
- name: Create public IP address
  azure_rm_publicipaddress:
    ...
  register: publicIP

- name: Create Network Security Group
  azure_rm_securitygroup:
    ...
  loop: "{{ NSGlist }}"
  register: NSG

- name: Create virtual network interface card(NIC) with public IP
  azure_rm_networkinterface:
    ...
  register: NIC
```

>*_Note_*: you can register a variable after each task and use "debug" to show the output. By doing so, you can also refer to value in the Azure resource by using e.g., `"{{ NIC.state.name }}"` in subsequent task.

For example:

```yml
  - name: Show NIC details
    debug:
      var: NIC
```

2. Move the task to create the VM to a file called `createvm.yml`. Let's add an additional configuration (a tag) to each VM.

    - For the front-end, add a tag by setting `tags: "Ansible=web"`
    - For the back-end, add a tag by setting `tags: "Ansible=MySQL"`

3. main.yml will be your main playbook. The structure is similar to this:  

```yml
- hosts: localhost
  vars_files:
    - ./vars.yml
    
  tasks:
  - name: Create a resource group
    azure_rm_resourcegroup:
      ...

  - name: Create a virtual network.
    azure_rm_virtualnetwork:
      ...

  - name: Create front-end subnet and NSG rules
    vars:
      ... 
    include_tasks: ./confignetwork.yml

  - name: Create a front-end virtual machines
    vars:
      ...
    include: ./createvm.yml
  
  - name: Create back-end subnet and NSG rules
    vars:
      ...
    include_tasks: ./confignetwork.yml

  - name: Create a back-end virtual machines
    vars:
      ...
    include: ./createvm.yml

```

> **_NOTE:_** You can refer to samples in [lab5](/lab5.)

## Dynamic inventory

If you wonder why we asked you to add tags to your VMs, that's because Ansible can pull inventory information from various sources including Azure resources into a dynamic inventory.

Starting with Ansible 2.8, Ansible provides an [Azure dynamic-inventory plugin](https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/inventory/azure_rm.py).

1. The inventory plugin requires a configuration file. The configuration file must end in azure_rm and have an extension of either yml or yaml. Save the following playbook as myazure_rm.yml:

```yml
plugin: azure_rm
auth_source: auto

include_vm_resource_groups:
- <<include name of your resource group here>>

keyed_groups:
- prefix: tag
  key: tags

```
1. Run the following command to ping 

```bash
ansible-inventory -i myazure_rm.yml --graph
```

You should see something like this:

```
@all:
  |--@tag_Ansible_SQL:
  |  |--myVM-BE_7ac4
  |--@tag_Ansible_web:
  |  |--myVM-FE_d407
  |--@tag__own_sa__myvmbe9129:
  |  |--myVM-BE_7ac4
  |--@tag__own_sa__myvmfe1348:
  |  |--myVM-FE_d407
  |--@ungrouped:

```

You can test connection to myVM-BE by doing:

```bash
ansible -u testadmin -i myazure_rm.yml -m ping tag_Ansible_web
```

Likewise, for myVM-FE, run:

```bash
ansible -u testadmin -i myazure_rm.yml -m ping tag_Ansible_MySQL
```

With dynamic inventory, you can run playbook by targeting vm(s) with the specific tag. For instance, if you wish to apply `mysql.yml` to the back-end VM, you can do so by running the command:

```bash
ansible-playbook -i myazure_rm.yml mysql.yml --limit=tag_Ansible_MySQL
```

For more details, refer to [Manage your Azure resources](https://docs.microsoft.com/en-us/azure/ansible/ansible-manage-azure-dynamic-inventories)


## Role

Roles facilitate reuse and further promote modularization of configuration. [Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) are known file structure that allows easy sharing with other uses.

Example of project structure:

```yml
site.yml
webservers.yml
fooservers.yml
roles/
   common/
     tasks/
     handlers/
     files/
     templates/
     vars/
     defaults/
     meta/
   webservers/
     tasks/
     defaults/
     meta/
```

In Lab 4, you saw how we embedded a development version of a module as part of a role. You can use the same mechanism to distribute in-house developed plugin.

The [AKS role](https://galaxy.ansible.com/azure/aks) we released in Ansible Galaxy is a good example on how you can reuse and share you can provision AKS cluster in your organization. 

## Additional useful resources

- [Ansible Roles Explained | Cheat Sheet](https://linuxacademy.com/blog/linux-academy/ansible-roles-explained/)
- [Ansible roles tutorialspoint](https://www.tutorialspoint.com/ansible/ansible_roles.htm)
