locals {

  username = var.username
  password = var.password

  resource_group_name     = "rg-fortinet-utility"
  resource_group_location = "eastus"

  virtual_network_name = "vnet-fortinet-utility"

  license_type = "flex"

  fortinet_serials = {
    "faz_serial" = {
      serial_number = var.faz_serial
    }
    "fmg_serial" = {
      serial_number = var.fmg_serial
    }
  }

  licenses = {
    "faz_license_file" = ""
    "faz_license_flex" = fortiflexvm_entitlements_vm_token.entitlements_vm_token["faz_serial"].token
    "fmg_license_file" = ""
    "fmg_license_flex" = fortiflexvm_entitlements_vm_token.entitlements_vm_token["fmg_serial"].token
  }

  vm_image = {
    "faz" = {
      publisher = "fortinet"
      offer     = "fortinet-fortianalyzer"
      sku       = "fortinet-fortianalyzer"
      vm_size   = "Standard_D8s_v5"
      version   = "latest" # an be a version number as well, e.g. 6.4.9, 7.0.6, 7.2.5, 7.4.0
    }
    "fmg" = {
      publisher = "fortinet"
      offer     = "fortinet-fortimanager"
      sku       = "fortinet-fortimanager"
      vm_size   = "Standard_D8s_v5"
      version   = "latest" # an be a version number as well, e.g. 6.4.9, 7.0.6, 7.2.5, 7.4.0
    }
  }

  resource_groups = {
    (local.resource_group_name) = {
      name     = local.resource_group_name
      location = local.resource_group_location
    }
  }

  public_ips = {
    "pip-faz" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-faz"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip-fmg" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-fmg"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  virtual_networks = {
    "vnet-fortinet-utility" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name          = local.virtual_network_name
      address_space = ["172.16.136.0/24"]
    }
  }

  subnets = {
    "snet-utility" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-utility"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space)[0], 0, 0)]
    }
  }

  network_interfaces = {
    "nic-faz_1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-faz_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-utility"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-utility"].address_prefixes[0], 4)
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-faz"].id
        }
      ]
    }
    "nic-fmg_1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fmg_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-utility"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-utility"].address_prefixes[0], 5)
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fmg"].id
        }
      ]
    }
  }


  network_security_groups = {
    "nsg-utility" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "nsg-utility"
    }
  }

  network_security_rules = {
    "nsgsr-utility_ingress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-utility_ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-utility"].name
    },
    "nsgsr-utility_egress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-utility_egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-utility"].name
    }
  }

  subnet_network_security_group_associations = {
    "snet-utility" = {
      subnet_id                 = azurerm_subnet.subnet["snet-utility"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-utility"].id
    }
  }

  linux_virtual_machines = {
    "vm-faz" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "vm-faz"
      size = local.vm_image["faz"].vm_size

      network_interface_ids = [azurerm_network_interface.network_interface["nic-faz_1"].id]

      identity_identity = "SystemAssigned"

      source_image_reference_publisher = local.vm_image["faz"].publisher
      source_image_reference_offer     = local.vm_image["faz"].offer
      source_image_reference_sku       = local.vm_image["faz"].sku
      source_image_reference_version   = local.vm_image["faz"].version

      plan_publisher = local.vm_image["faz"].publisher
      plan_product   = local.vm_image["faz"].offer
      plan_name      = local.vm_image["faz"].sku

      os_disk_name                 = "osdisk-faz"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      admin_username                  = local.username
      admin_password                  = local.password
      disable_password_authentication = false
      custom_data = base64encode(templatefile("${path.module}/templates/faz-customdata.conf", {
        vm_name      = "vm-faz"
        license_file = local.licenses["faz_license_file"]
        license_flex = local.licenses["faz_license_flex"]
      }))
    }
    "vm-fmg" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "vm-fmg"
      size = local.vm_image["fmg"].vm_size

      network_interface_ids = [azurerm_network_interface.network_interface["nic-fmg_1"].id]

      identity_identity = "SystemAssigned"

      source_image_reference_publisher = local.vm_image["fmg"].publisher
      source_image_reference_offer     = local.vm_image["fmg"].offer
      source_image_reference_sku       = local.vm_image["fmg"].sku
      source_image_reference_version   = local.vm_image["fmg"].version

      plan_publisher = local.vm_image["fmg"].publisher
      plan_product   = local.vm_image["fmg"].offer
      plan_name      = local.vm_image["fmg"].sku

      os_disk_name                 = "osdisk-fmg"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      admin_username                  = local.username
      admin_password                  = local.password
      disable_password_authentication = false
      custom_data = base64encode(templatefile("${path.module}/templates/fmg-customdata.conf", {
        vm_name      = "vm-fmg"
        port1_ip     = cidrhost(azurerm_subnet.subnet["snet-utility"].address_prefixes[0], 5)
        port1_mask   = cidrnetmask(azurerm_subnet.subnet["snet-utility"].address_prefixes[0])
        port1_gw     = cidrhost(azurerm_subnet.subnet["snet-utility"].address_prefixes[0], 1)
        license_file = local.licenses["fmg_license_file"]
        license_flex = local.licenses["fmg_license_flex"]
      }))
    }
  }

  managed_disks = {
    "disk-faz-data-01" = {

      location             = azurerm_resource_group.resource_group[local.resource_group_name].location
      resource_group_name  = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                 = "disk-faz-data-01"
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 1024
    }
    "disk-fmg-data-01" = {

      location             = azurerm_resource_group.resource_group[local.resource_group_name].location
      resource_group_name  = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                 = "disk-fmg-data-01"
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 1024
    }
  }

  virtual_machine_data_disk_attachments = {
    "faz_data_disk_attachment" = {
      managed_disk_id    = azurerm_managed_disk.managed_disk["disk-faz-data-01"].id
      virtual_machine_id = azurerm_linux_virtual_machine.linux_virtual_machine["vm-faz"].id
      lun                = "1"
      caching            = "ReadWrite"
    }
    "fmg_data_disk_attachment" = {
      managed_disk_id    = azurerm_managed_disk.managed_disk["disk-fmg-data-01"].id
      virtual_machine_id = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fmg"].id
      lun                = "1"
      caching            = "ReadWrite"
    }
  }
}