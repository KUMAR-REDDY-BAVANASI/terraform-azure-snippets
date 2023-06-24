terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "terrformtfstatebackend"
  #   container_name       = "tfstate"
  #   key                  = "mssqlvm/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-todo-dev-eastus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg-todo-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "RDPRule" {
  name                        = "nsgsr-rdpallow-001"
  resource_group_name         = azurerm_resource_group.example.name
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 3389
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_network_security_rule" "MSSQLRule" {
  name                        = "nsgsr-mssqlallow-001"
  resource_group_name         = azurerm_resource_group.example.name
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 27178
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_network_interface" "example" {
  name                = "nic-todo-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "exampleconfiguration1"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_virtual_machine" "example" {
  name                  = var.virtual_machine_name
  vm_size               = "Standard_B4ms"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]

  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "Osdisk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.virtual_machine_name}-DATA"
    caching           = "ReadOnly"
    create_option     = "Empty"
    disk_size_gb      = 256
    lun               = 0
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.virtual_machine_name}-LOG"
    caching           = "None"
    create_option     = "Empty"
    disk_size_gb      = 128
    lun               = 1
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    timezone                  = "Pacific Standard Time"
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_mssql_virtual_machine" "example" {
  virtual_machine_id = azurerm_virtual_machine.example.id
  sql_license_type   = "PAYG"

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "OLTP"

    data_settings {
      default_file_path = "F:\\Data"
      luns              = [0]
    }

    log_settings {
      default_file_path = "G:\\Log"
      luns              = [1]
    }

    temp_db_settings {
      default_file_path      = "G:\\tempDb"
      luns                   = [1]
      data_file_count        = 8
      data_file_size_mb      = 8
      data_file_growth_in_mb = 64
      log_file_size_mb       = 8
      log_file_growth_mb     = 64
    }
  }

}

# resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
#   name                       = "vm_extension_install_iis"
#   virtual_machine_id         = azurerm_virtual_machine.example.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.8"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#         "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
#     }
# SETTINGS
# }

# ##########################################################
# ## Install IIS on VM
# ##########################################################

# resource "azurerm_virtual_machine_extension" "iis" {
#   name                 = "install-iis"
#   resource_group_name  = "${var.resource_group_name}"
#   location             = "${var.location}"
#   virtual_machine_name = "${var.vmname}"
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   settings = <<SETTINGS
#     { 
#       "commandToExecute": "powershell Add-WindowsFeature Web-Asp-Net45;Add-WindowsFeature NET-Framework-45-Core;Add-WindowsFeature Web-Net-Ext45;Add-WindowsFeature Web-ISAPI-Ext;Add-WindowsFeature Web-ISAPI-Filter;Add-WindowsFeature Web-Mgmt-Console;Add-WindowsFeature Web-Scripting-Tools;Add-WindowsFeature Search-Service;Add-WindowsFeature Web-Filtering;Add-WindowsFeature Web-Basic-Auth;Add-WindowsFeature Web-Windows-Auth;Add-WindowsFeature Web-Default-Doc;Add-WindowsFeature Web-Http-Errors;Add-WindowsFeature Web-Static-Content;"
#     } 
# SETTINGS
# }