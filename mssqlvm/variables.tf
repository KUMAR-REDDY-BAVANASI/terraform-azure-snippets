variable "resource_group" {
  description = "Name of the azure resource_group"
  default     = "rg-todo-dev-001"
}

variable "location" {
  description = "The Azure location where all resources should be created."
  default     = "eastus"
}

variable "virtual_network_name" {
  description = "name of virtual_network"
  default     = "vnet-dev-eastus-001"
}

variable "subnet_name" {
  description = "name of subnet"
  default     = "snet-dev-eastus-001"
}

variable "virtual_machine_name" {
  description = "name of virtual_machine"
  default     = "vmtododev001"
}

variable "publisher" {
  default = ""
}

variable "offer" {
  default = ""
}

variable "sku" {
  default = ""
}

variable "computer_name" {
  default = ""
}

variable "admin_username" {
  default = ""
}

variable "admin_password" {
  default = ""
}