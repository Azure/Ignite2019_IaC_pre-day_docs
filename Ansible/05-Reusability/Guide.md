# Reusability

In this section you will:

- include a task or list of tasks in your play
- learn how to use Dynamic Inventory
- get an introduction to Ansible roles

## Before you start

For this lab, you will work with multiple files. 

Running playbooks in Cloud Shell presents a couple of limitations:

- you can only upload file to Cloud Shell one by one
- after uploading to Cloud Shell, you need to perform an additional step to move files uploaded to the right location.

It can become cumbersome to continue running your playbook in Cloud Shell.

The VS Code Ansible extension provides better integration experience when you need to work with multiple files so we recommend running Ansible in the remote host via SSH. You can hit `F1` to copy files to remote host.

1. Hit `F1`; type "Ansible: copy folder to Remote Host"
1. Follow the prompt to provide the source directory
1. Select "Set up host" if this is the first time. Else select your remote host
1. Next specify the target folder

## Reusing task(s) in your playbook

You can use the [include](https://docs.ansible.com/ansible/latest/modules/include_module.html) and [include_tasks](https://docs.ansible.com/ansible/latest/modules/include_tasks_module.html#include-tasks-module) modules to dynamically include a task or a list of tasks.

Let's modify what you have done so far to create a multi-tier application. 

Based on the Azure CLI sample, let's build a [network of multi-tier applications](https://docs.microsoft.com/en-us/azure/virtual-network/scripts/virtual-network-cli-sample-multi-tier-application). 

- a virtual network (172.16.0.0/16) with front-end (172.16.10.0/24) and back-end (176.16.20.0/24) subnets:
    - Traffic to the front-end subnet is limited to HTTP and SSH
    - Traffic to the back-end subnet is limited to MySQL, port 3306 and SSH. All outbound traffic from  the back-end subnet should be blocked.
- two virtual machines, one in each subnet

What you have done so far:
- A VNet 172.16.0.0/16
- A front-end subnet - 172.16.10.0/24 with NSG rules that allow:
    - SSH traffic from the Internet to the front-end subnetSSH on port 22
    - HTTP traffic in from the Internet to the front-end subnet on port 80
- And a VM in the front-end subnet that can act as the front-end web server

You need to add:
- A backend subnet 172.16.20/24 with NSG rules that:
  - allows SSH traffic from the Internet to the front-end subnet on port 22
  - allows MySQL traffic from the front-end subnet to the back-end subnet on port 3306
  - blocks all outbound traffic from the back-end subnet to the Internet
- A VM in the back-end subnet.

![Sample multi-tier applications](../../Terraform/05%20-%20Reusability/Assets/labnet.png "Azure resources to be provisioned.")

Let's start by restructuring your playbook and break the tasks out into a few playbooks.

1. Move all common tasks related to subnet configuration to one YAML file say configurenetwork.yml so that you can use the same list of tasks to provision and configure the subnet, public IP etc. networking related tasks.

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

>**Note**: you can register a variable after each task and use "debug" to show the output. By doing so, you can also refer to value in the Azure resource by using e.g., `"{{ NIC.state.name }}"` in subsequent task.

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

> **CODE**: To view all of the completed codes, go to [lab5](/lab5).

## Dynamic inventory

If you wonder why we asked you to add tags to your VMs, that's because Ansible can pull inventory information from various sources including Azure resources into a dynamic inventory.

Starting with Ansible 2.8, Ansible provides an [Azure dynamic-inventory plugin](https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/inventory/azure_rm.py).

1. The inventory plugin requires a configuration file. The configuration file must end in `azure_rm` and have an extension of either yml or yaml. Save the following playbook as myazure_rm.yml:

```yml
plugin: azure_rm
auth_source: auto

include_vm_resource_groups:
- <<include name of your resource group here>>

keyed_groups:
- prefix: tag
  key: tags

```

1. Run the following command to view the populated inventory: 

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
ansible -u testadmin -i myazure_rm.yml -m ping tag_Ansible_web -k
```



Likewise, for myVM-FE, run:

```bash
ansible -u testadmin -i myazure_rm.yml -m ping tag_Ansible_MySQL -k
```

>**_Note_**: since the VMs are using userid/password for authentication, you need to add `-k` to the command and provide password used to SSH into the VMs.

With dynamic inventory, you can run playbook by targeting vm(s) with the specific tag. For instance, if you wish to apply `XXX.yml` to the back-end VM, you can do so by running the command:

```bash
ansible-playbook -i myazure_rm.yml XXX.yml --limit=tag_Ansible_MySQL
```

For more details, refer to [Manage your Azure resources](https://docs.microsoft.com/en-us/azure/ansible/ansible-manage-azure-dynamic-inventories)


## Roles

To take it one step further, you can create Roles so that you can reuse and further promote modularization of configuration.

[Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) are known file structure that allows easy sharing with other uses within and outside of your organization. It is a group of variables, tasks, files, and handlers that are stored in a standardized file structure.

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

[Ansible Galaxy or Galaxy](https://docs.ansible.com/ansible/latest/reference_appendices/galaxy.html), is a free site for finding, downloading, and sharing community developed roles. Downloading roles from Galaxy is a great way to jumpstart your automation projects.

You can also use the ansible_galaxy command line tool to create new roles by running:

```bash
$ ansible-galaxy init role_name
```

Roles may also include modules and other plugin types. In Lab 4, you saw how we embedded a development version of an Azure module as part of a role. You can use the same mechanism to distribute in-house developed plugin.

For further exploration, the [AKS role](https://galaxy.ansible.com/azure/aks) we shared in Ansible Galaxy is a good example on how you can reuse and share common configurations and tasks to provision AKS cluster in your organization.

## Further readings

- [Ansible Galaxy](https://galaxy.ansible.com)
- [Ansible Roles Explained | Cheat Sheet](https://linuxacademy.com/blog/linux-academy/ansible-roles-explained/)
- [Ansible roles tutorialspoint](https://www.tutorialspoint.com/ansible/ansible_roles.htm)
