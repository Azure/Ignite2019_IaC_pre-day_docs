variable "rg" {
  type        = "string"
  description = "Name of Lab resource group to provision resources to."
}

variable "secret_id" {
  type        = "string"
  description = "name of secret containing admin password for vms"
}

variable "labUser" {
  type        = "string"
  description = "Username for lab account"
}

variable "tenantId" {
  type        = "string"
  description = "Id for tenant"
}

variable "key_vault" {
  type        = "string"
  description = "Name of the pre-existing key vault instance"
}