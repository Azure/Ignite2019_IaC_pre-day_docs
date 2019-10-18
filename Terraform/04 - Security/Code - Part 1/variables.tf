variable "rg" {
  description = "Name of Lab resource group to provision resources to."
}

variable "secretId" {
  description = "name of secret containing admin password for vms"
}

variable "labUser" {
  description = "Username for lab account"
}

variable "tenantId" {
  description = "Id for tenant"
}

variable "keyVault" {
  description = "Name of the pre-existing key vault instance"
}