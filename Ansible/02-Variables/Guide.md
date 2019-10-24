# Variables

In this section you will:

- Create a network security group
- Create a Network Interface Card (NIC)
- Create a Virtual Machine

## Overview

Apart from provisioning a network interface card(NIC) as well as a virtual machine, you will modify the playbook you created in previous lab to work with variables.

## Adding variables to your playbook

Modify your playbook created in previous lab to replace hard-coded values as variables.

You can define variables directly inline. By adding `vars:` in the header.

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

> **NOTE:** To get value from environment variable, do  `"{{ lookup('env', 'AZURE_CLIENT_ID') }}"`

## Create a public IP address

Public IP addresses allow Internet resources to communicate inbound to Azure resources.

1. Add a new variable called `myPublicIP` to your playbook
1. Use the [azure_rm_publicipaddres](https://docs.ansible.com/ansible/latest/modules/azure_rm_publicipaddress_module.html) to create a Public IP Address.
1. Run your playbook.

#### Cheat Sheet: public IP address
<details>
<summary>
Expand to see how you can create a public IP address
</summary>

```yaml
  - name: Create public IP address
    azure_rm_publicipaddress:
      resource_group: "{{ myResource_group }}"
      allocation_method: Static
      name: "{{ myPublicIP }}"
```

</details>

## Create a Network Interface Card (NIC)

A network interface enables an Azure Virtual Machine to communicate with internet, Azure, and on-premises resources.

1. Add to your existing playbook a variable call `myNIC`.
2. Use the [azure_rm_networkinterface](https://docs.ansible.com/ansible/latest/modules/azure_rm_networkinterface_module.html) to complete this step.
3. Run your playbook.

You can now see `myNIC` in your resource group.

#### Cheat Sheet: NIC
<details>
<summary>
Expand to see how you can create a subnet
</summary>

```yaml
    azure_rm_networkinterface:
      resource_group: "{{ myResource_group }}"
      name: "{{ myNIC }}"
      virtual_network: "{{ myVnet }}"
      subnet: "{{ myVnetSubNet }}"
      ip_configurations:
        - name: ipconfig
          public_ip_address_name: "{{ myPublicIP }}"
```

</details>

## Create a virtual machine

1. Add to your existing playbook a variable call `myVM`.
2. Use the [azure_rm_virtualmachine](https://docs.ansible.com/ansible/latest/modules/azure_rm_virtualmachine_module.html) to complete this step. Use the following configurations for image:
    - offer: UbuntuServer
    - publisher: Canonical
    - sku: 16.04-LTS
    - version: latest
3. To simplify, let's create a VM that uses admin user `testadmin` and a password `Password1234!` to access the host.
4. Run your playbook.

#### Cheat Sheet: VM
<details>
<summary>
Expand to see how you can create a VM using SSH key to access the host.
</summary>
- To create a VM using password

```yml
  - name: Create a virtual machine
    azure_rm_virtualmachine:
      resource_group: "{{ myResource_group }}"
      name: "{{ myVM }}"
      admin_username: "testadmin"
      admin_password: "Password1234!"
      vm_size: Standard_B1ms
      network_interfaces: "{{ myNIC }}"
      image:
        offer: UbuntuServer
        publisher: Canonical
        sku: 16.04-LTS
        version: latest
  ```

- To create a VM using SSH key:

```yaml
- name: Create a virtual machines
  azure_rm_virtualmachine:
    resource_group: "{{ myResource_group }}"
    name: "{{ myVM }}"
    admin_username: "testadmin"
    ssh_password_enabled: false
    ssh_public_keys:
      - path: /home/testadmin/.ssh/authorized_keys
        key_data: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
    vm_size: Standard_B1ms
      network_interfaces: "{{ myNIC }}"
      image:
        offer: UbuntuServer
        publisher: Canonical
        sku: 16.04-LTS
        version: latest
```



</details>

You can go to [Azure portal](https://portal.azure.com) to verify that you have created the resources.

> **CODE**: To view all of the completed code for this part of the lab, go [here](lab2.yml).

## Registering variables and working with conditionals

The value of a task being executed in Ansible can be saved in a variable and used later in conjunction with the `when` clause.

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

You can register a variable for the output of a task. Use `set_facts` to assign the value of another variable based on a specific value in the output and use it for subsequent task(s.) 

```yml
  tasks:

    - name: List all the resources under a resource group
      azure_rm_resource_facts:
        resource_group: "{{ resource_group }}"
        resource_type: resources
      register: output

    - name: Dump raw list of resouces in the resource group
      debug:
        var: output

    - name: Create a list of resource IDs
      set_fact:
        resource_ids: "{{ output.response | map(attribute='id') | list }}"
```

This [playbook sample](https://github.com/Azure-Samples/ansible-playbooks/blob/master/rest/resourcegroup_dump_resources.yml) is a good walk-through to see how you can perform a complete dump of resources using the [azure_resource_facts](https://docs.ansible.com/ansible/latest/modules/azure_rm_resource_facts_module.html) module.

## Additional useful resources

- facts are information derived from speaking with your remote systems. You can find a complete set under the `ansible_facts` variable. Refer to [this](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variables-discovered-from-systems-facts) for more information. 
- you can assign values to variables defined in playbooks when you run your playbook by doing so:

```bash
ansible-playbook xxx.yml -e "myResource_group=XXXXXX myVM=XXXXXX"
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

> **CODE**: The [Code](../03-Helpers/Lab3/Code) folder in **Lab #3 - 03-Helpers** contains the sample playbook and vars.yml you can refer to.

- Refer to [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html) for more details and ways to use variables.