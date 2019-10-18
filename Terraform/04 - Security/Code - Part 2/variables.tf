variable "rg" {
  type        = "string"
  description = "Name of Lab resource group to provision resources to."
}

variable "location" {
  type        = "string"
  description = "Azure region to put resources in"
}

variable "secretId" {
  type        = "string"
  description = "name of secret containing admin password for vms"
}

variable "keyVault" {
  type        = "string"
  description = "Name of the pre-existing key vault instance"
}