# Challenges
The final hands on part of the the pre-day consists of two challenges where you will pick 2 of the 4 challenges. You have 1 hr for each challenge and will be scored based on the requirements that you are able to implement and provision. You man choose any of the tools or any combination thereof to accomplish your chosen challenge. 

As they have been with the labs, our proctors are here to help so feel free to flag one of us down if you get stuck or have questions.

Once you have completed your challenge, please flag down one of the proctors who will check your work and record your score.

At the end of the day, the person(s) with the most points will be win a fabulous prize!
> In case of a tie we will raffle amongst the top scorers

## Securely provision Azure Kuberenets cluster
For this challenge, you will provision an [Azure Kubernetes](https://docs.microsoft.com/en-us/azure/aks/) (AKS) Cluster that meets the following requirements. 

| Requirement                                                                   | Points |
|:------------------------------------------------------------------------------|:------:|
| Kuberenetes Cluster with auto scaling Linux nodes                             |   30   |
| Connect to custom / existing VNet                                             |   20   |
| Enable Container monitoring with Log Analytics                                |   30   |
| Connect to Azure Container Instances (ACI) for burstability                   |   20   |

> **NOTE** All secrets must be securely stored and referenced (i.e. nothing in plain text)

## Web App with CosmoDB backend
For this challenge, you will provision an [Azure WebApp](https://docs.microsoft.com/en-us/azure/app-service/) and a [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/introduction) that meets the following requirements.

| Requirement                                                                                       | Points |
|:--------------------------------------------------------------------------------------------------|:------:|
| Cosmos DB using the MongoDb API                                                                   |   20   |
| Azure Web App (App Service)for NodeJS with System Assigned identity, storage for application logs |   30   |
| Enable monitoring of app & cosmos with Log Analytics                                              |   25   |
| Connect WebApp and Cosmos DB using VNet                                                           |   25   |

> **NOTE** All secrets must be securely stored and referenced (i.e. nothing in plain text)

## Provision VMSS with image from Shared Image Gallery
For this challenge, you will provision an create a [VMSS](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) (SIG) from an image that is stored in the [Shared Image Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries) (SIG) that meets the following requirements.

| Requirement                                                                   | Points |
|:------------------------------------------------------------------------------|:------:|
| Shared Image Gallery with image to be used by VMSS                            |   30   |
| VMSS with 3 instances using SIG image plus a managed data disk                |   30   |
| Use Rolling upgrade policy in VMSS                                            |   40   |

> **NOTE** All secrets must be securely stored and referenced (i.e. nothing in plain text)


## Pipeline for IaC
For this challenge, you will provision an create a pipeline that will build and provision code from the Hands on Labs or a previous challeng. You can use the Azure DevOps environement that has been provisioned as part of this lab environment, GitHub Actions or Jenkins for your pipeline.  The pipelien must meet the following requirements.

| Requirement                                                                               | Points |
|:------------------------------------------------------------------------------------------|:------:|
| Create Build Step that performs some basic checks of your IaC (linting, plan, etc.)       |   50   |
| Create a Deploy step that deploys the infrastructure                                      |   50   |

> **NOTE** All secrets must be securely stored and referenced (i.e. nothing in plain text)

------------

> **EXTRA CREDIT** If you are an over achiever and have the time, you can do up to one additional challenge.