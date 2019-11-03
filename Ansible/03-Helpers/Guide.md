# Ansible Lab 3 - Iterators and Helpers

In this lab you will:

- Create a network security group (NSG) and add rules to the NSG

## Overview

Apart from creating the new Azure resource, you will modify the playbook you created in previous labs to use loops.

## Create a network security group

Network security groups filter network traffic between Azure resources in a virtual network.

1. Add to your existing playbook a new variable called `myNetworkSecurityGroup`.
1. Use the [azure_rm_securitygroup](https://docs.ansible.com/ansible/latest/modules/azure_rm_securitygroup_module.html) to create a network security group that allows SSH traffic on TCP port 22.
1. Add the NSG to the NIC you created in previous lab.
1. Run your playbook.

Next, let's add more inbound rules to open some ports. A direct way is to do the following:

```yml
  - name: Create Network Security Group that allows SSH,HTTP and 
    azure_rm_securitygroup:
      resource_group: "{{ myResource_group }}"
      name: "{{ myNetworkSecurityGroup}}"
      rules:
        - name: Allow-SSH
          access: Allow
          protocol: Tcp
          direction: Inbound
          destination_port_range: 22
          priority: 300
          source_address_prefix: Internet
        - name: Allow-HTTP
          access: Allow
          protocol: Tcp
          direction: Inbound
          destination_port_range: 80
          priority: 100
          source_address_prefix: Internet
        - name: Allow-443
          protocol: Tcp
          destination_port_range: 443
          access: Allow
          priority: 200
          direction: Inbound
          source_address_prefix: Internet
```

You may want to block some ports as well so, perhaps you will add another rule like this:

```yml
        - name: Deny-Internet-all
          protocol: Tcp
          destination_port_range: *
          access: Deny
          priority: 400
          direction: Outbound
          source_address_prefix: *
```

As you create more NSG rules, your playbook can become lengthy and unmanageable.

The good news is, you can make use of `loops` to reduce the lines of codes and improve readability. After all, Ansible is simple and the playbooks are human-readable.

## Loops

[Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html) has more detailed information on loops. We will focus on some standard ways to use the `loop` keyword in this lab.

Repeated tasks can be written as a standard loop over a simple list of strings.

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

You can have a list of hash. Each item in the list is a list of key/value pairs, commonly called a “hash” or a “dictionary”.

In the example below, the user task is run once for each key/value pair in the list. 

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

Can you try to reduce the lines of security group configurations by using loop?

#### Cheat Sheet: NSG
<details>
<summary>
Expand to see how you use loop to create the NSG rules
</summary>


```yaml
  - name: Create Network Security Group and rules
    azure_rm_securitygroup:
      resource_group: "{{ myResource_group }}"
      name: "{{ myNetworkSecurityGroup}}"
      rules:
        - name: "{{ item.name }}"
          access: "{{ item.access }}"
          protocol: "{{ item.protocol }}"
          direction: "{{ item.direction }}"
          destination_port_range: "{{ item.port }}"
          priority: "{{ item.priority }}"
          source_address_prefix: "{{ item.source_address_prefix }}"
    loop: "{{ NSGlist }}"
```

- the NSG rule list `NSGlist` can be defined as a list of hash:
    -  `[{ name: 'Allow-SSH', access: 'Allow', protocol: 'Tcp', direction: 'Inbound', priority: '300', port: '22', source_address_prefix: 'Internet'},{ name: 'Allow-HTTP', access: 'Allow', protocol: 'Tcp', direction: 'Inbound', priority: '100', port: '80', source_address_prefix: 'Internet'}]`
    -  I prefer to do it this way for readability:
    
    ```yml
        NSGlist: 
          - name: Allow-SSH
            access: Allow
            protocol: Tcp
            direction: Inbound
            priority: 300
            port: 22 
            source_address_prefix: Internet
          - name: Allow-HTTP
            access: Allow
            protocol: Tcp
            direction: Inbound
            priority: 100
            port: 80
            source_address_prefix: Internet
    ```
</details>

> **CODE**: To view all of the completed codes, go to [lab3.yml](Code/lab3.yml).