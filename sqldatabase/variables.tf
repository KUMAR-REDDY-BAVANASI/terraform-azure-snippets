
variable "resource_group" {
  description = "Name of the azure resource_group"
  default     = "rg-todo-dev-001"
}

variable "location" {
  description = "The Azure location where all resources should be created."
  default     = "eastus"
}

variable "sqlServerName" {
  description = "Name of the SQL Server"
  default     = ""
}

variable "sqlServerAdminName" {
  description = "Sql Server Admin User Name"
  default     = ""
}

variable "sqlServerAdminPassword" {
  description = "Sql Server Admin User Password"
  default     = ""
}

variable "sqlDatabaseName" {
  description = "Name of the Database"
  default     = ""
}