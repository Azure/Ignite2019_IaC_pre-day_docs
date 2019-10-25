# Ignite 2019 - Infrastructure as code with Terraform, Ansible, and ARM Pre-Day Workshop
Infrastructure as code (IaC) is an important pillar of modern DevOps and is used by most enterprise customers to safely and efficiently provision and manage their cloud solutions. HashiCorp Terraform and Red Hat Ansible are very popular technologies allowing the practice of IaC - they abstract infrastructure provisioning, making it faster and easier for teams to deploy cloud resources in a variety of scenarios such as hybrid and multi cloud environments. In this workshop, learn about the practice of infrastructure as code, get an overview of Terraform, Ansible, and Azure Resource Manager templates, as well as gain hands-on experience in using these to deploy and provision resources on Azure. 

Walk throughs for this workshop can be found in the table below. During the workshop, you will pick a track or tool and work through each of the labs for that tool. If you have extra time during the workship or if you would like to come back and walk through the labs with the other tools after the workshop this table will enable you to do that.

## Workshop Labs

| Lab Name      | Ansible       | ARM Template  | Terraform |
|:------------- |:-------------:|:-------------:|:-------------:|
| Basics        | [Guide](./Ansible/01-Basics/Guide.md) | [Guide](./ARM%20Template/01%20-%20Basics/Guide.md) | [Guide](./Terraform/01%20-%20Basics/Guide.md) |
| Variables     | [Guide](./Ansible/02-Variables/Guide.md) | [Guide](./ARM%20Template/02%20-%20Variables/Guide.md) | [Guide](./Terraform/02%20-%20Variables/Guide.md) |
| Helpers       | [Guide](./Ansible/03-Helpers/Guide.md) | [Guide](./ARM%20Template/03%20-%20Helpers/Guide.md) | [Guide](./Terraform/03%20-%20Helpers/Guide.md) |
| Security      | [Guide](./Ansible/04-Security/Guide.md) | [Guide](./ARM%20Template/04%20-%20Security/Guide.md) | [Guide](./Terraform/04%20-%20Security/Guide.md) |
| Reusability   | [Guide](./Ansible/05-Reusability/Guide.md) | [Guide](./ARM%20Template/05%20-%20Reusability/Guide.md) | [Guide](./Terraform/05%20-%20Reusability/Guide.md) |

## Before you start

Go to [launch URL](https://manage.cloudlabs.ai/#/odl/ac646c05-db3c-4773-a2b6-799f80eac16b), sign up and provide the activation code.

After you signed up, click the Launch Lab button which will take you automatically to the LabVM RDP in browser.

### Setting up Cloud Shell in Azure portal

In the LabVM RDP browser:

1. Click the link on the top left to go to **Azure Portal** 
1. Sign in using the **Azure Credentials** provided in the `Environment Details` tab
1. Once signed in, go to **Resource Groups** under **Favorites** in the left rail. You should see two resource groups: 
    - IoC-01-XXXXXX: this resource group contains all the AnsibleVM, LabVMs etc., lab resources. We recommend to put your Cloud Shell storage in this resource group as well.
    - IoC-02-XXXXXX: use this resource group for all assets created in the labs

1. click >_ in the top bar
![Launch Cloud Shell](/images/cloudshell.png)
1. Select `Bash`
1. Since you have no storage mounted, click `Show advanced settings` to create a storage account in the 1st resource group.
![Launch Cloud Shell](/images/setup-cloudshell.png)
1. Specify the region as the same as your resource group. i.e. **South Central US**
1. Under `Resource group`, make sure you select `IoC-01-XXXXXX` as the resource group, provide a unique name for each of your storage account and file share. E.g., you can prefix the name with the last 6 digits of your resource group.


[Contribution guide](Contrib.md)
