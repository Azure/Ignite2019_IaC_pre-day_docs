variable "rg" {
  type        = "string"
  description = "Name of Lab resource group to provision resources to."
}

variable "location" {
  type        = "string"
  description = "Azure region to put resources in"
}

variable "custom_rules" {
  description = "Security rules for the network security group"
  type        = list(object({
    name                  = string
    priority              = number
    direction             = string
    access                = string
    protocol              = string
    destination_port_range= string
  }))
  default     = []
}

variable "securityGroupRules" {
  type        = list(object({
    name                  = string
    priority              = number
    protocol              = string
    destinationPortRange  = string
  }))
  description = "List of security group rules"
}

variable "tags" {
  type        = map(string)
  description = "tags to be used with all resources in the lab"
}