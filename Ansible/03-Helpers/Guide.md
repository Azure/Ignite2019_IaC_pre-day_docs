# Iteration and Helpers

In this section you will:

- Create a network security group(NSG) and add rules to the NSG

## Overview

Apart from creating the new Azure resources, you will modify the playbook you created in previous labs to use loops and dynamic inventory.

## Create a network security group

Network security groups filter network traffic between Azure resources in a virtual network.

1. Add to your existing playbook a new variable called `myNetworkSecurityGroup`
1. Use the [azure_rm_securitygroup](https://docs.ansible.com/ansible/latest/modules/azure_rm_securitygroup_module.html) to create a network security group that allows SSH traffic on TCP port 22.
1. Add the NSG to the NIC you created in previous lab.
1. Run your playbook.

Next, let's add more inbound rules to open ports 80 and 443 as well. A direct way is to do the following:

```yml
  - name: Create Network Security Group that allows SSH,HTTP and 
    azure_rm_securitygroup:
      resource_group: "{{ myResource_group }}"
      name: "{{ myNetworkSecurityGroup}}"
      rules:
        - name: Allow-SSH
          protocol: Tcp
          destination_port_range: 22
          access: Allow
          priority: 300
          direction: Inbound
        - name: Allow-HTTP
          protocol: Tcp
          destination_port_range: 80
          access: Allow
          priority: 100
          direction: Inbound
        - name: Allow-443
          protocol: Tcp
          destination_port_range: 443
          access: Allow
          priority: 200
          direction: Inbound
```

You can make use of `loops` to reduce the lines of codes and improve readability. After all, Ansible is simple and human-readable.

## Loops

[Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html) has more detailed information on loops. We will focus on some standard ways to using the `loop` keyword. 

Repeated tasks can be written as a standard loops over a simple list of string. 

For example:

```yml
- name: add several users
  user:
    name: "{{ item }}"
    state: present
    groups: "wheel"
  loop:
     - testuser1
     - testuser2
```

You can have a list of hashes.

```yml
- name: add several users
  user:
    name: "{{ item.name }}"
    state: present
    groups: "{{ item.groups }}"
  loop:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
```

Can you try to reduce the lines of codes from 23 to 11 (not including the loop keyword and list of hashes?

> **_NOTE:_** You can refer to [lab3.yml](lab3.yml) for a complete sample playbook. Make sure you also copy `vars.yml` to clouddrive. 