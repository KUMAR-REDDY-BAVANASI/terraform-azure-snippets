provider "azurerm" {
  features {}
}

resource "azurerm_mssql_server" "example" {
  name                         = var.sqlServerName
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sqlServerAdminName
  administrator_login_password = var.sqlServerAdminPassword
}

resource "azurerm_mssql_database" "example" {
  name           = var.sqlDatabaseName
  server_id      = azurerm_mssql_server.example.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S0"
  create_mode    = "Default"
  zone_redundant = "true"
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_mssql_firewall_rule" "example" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.example.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}