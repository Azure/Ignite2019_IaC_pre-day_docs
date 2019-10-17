# Security

In this section you will:

- Create secret in existing Key Vault (use secret instead of ssh key)
- Reference secret in configuration 

## Overview

In any real world Infrastructure as Code project, you will have secrets such as tokens, passwords, connection strings, certificats, encryption keys, etc. that are required in order to provision the desired resources. Although these are required by the code, you should NOT include the actual secret in the code. There are a number of ways to reference secrets from code of varying ease of use and security. In this lab, we will be using a central store, Azure Key Vault, to store, manage and reference our secrets.

This lab consists of two parts: 
In part 1, you will creat a secret that will be stored in Azure Key Vault. Although you will be performing and authenticating both of these actions as a single lab user, in the real world, the secrets could and typically would be created and stored by a separate user who would grant the end user or process permission to a given secret. 
In part 2, you will reference and use the secret stored in Azure Key Vault in your configuration. Referencing secrets in this manner will ensure that the secret is not exposed in code but also allows the secret to be changed / rotated without changing your code. 

## Part 1

### Create Secret

### Use Secret



