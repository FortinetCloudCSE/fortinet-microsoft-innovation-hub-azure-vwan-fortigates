locals {

  admin_username = var.admin_username
  admin_password = var.admin_password

  resource_group_name     = "rg-branch-sdwan-clients-eastus"
  resource_group_location = "eastus"

  virtual_network_name = "vnet-branch-sdwan-clients-eastus"

  resource_groups = {
    (local.resource_group_name) = {
      name     = local.resource_group_name
      location = local.resource_group_location
    }
  }


  virtual_networks = {
    (local.virtual_network_name) = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name          = local.virtual_network_name
      address_space = ["172.20.0.0/16"]
    }
  }

  # Create a map of subnets from Resource Groups and desired Subnet count
  subnet_list = setproduct(["snet-branch-sdwan-spoke-"], ["1", "2"])
  subnets = {
    for item in local.subnet_list :
    format("%s%s", item[0], item[1]) => {
      resource_group_name  = azurerm_resource_group.resource_group[local.resource_group_name].name,
      location             = azurerm_resource_group.resource_group[local.resource_group_name].location,
      name                 = format("%s%s", item[0], item[1]),
      address_prefixes     = [format("172.20.%s0.0/24", item[1])],
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
    }
  }

  # Create a map of linux VM NICs from Resource Groups and desired VM Nic count
  network_interface_list = setproduct(["nic-linux-branch-sdwan-spoke"], ["1", "2"])
  network_interfaces = {
    for item in local.network_interface_list :
    format("%s-%s", item[0], item[1]) => {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name,
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location,
      name                = format("%s-%s", item[0], item[1])
      ip_configuration = {
        name                          = "ipconfig",
        subnet_id                     = azurerm_subnet.subnet[format("snet-branch-sdwan-spoke-%s", item[1])].id,
        private_ip_address_allocation = "Dynamic"
      }
    }
  }

  # Create a map of linux VMs from Resource Groups and desired VM count
  linux_virtual_machine_list = setproduct(["vm-linux-branch-sdwan-spoke"], ["1", "2"])
  linux_virtual_machines = {
    for item in local.linux_virtual_machine_list :
    format("%s-%s", item[0], item[1]) => {
      resource_group_name          = azurerm_resource_group.resource_group[local.resource_group_name].name,
      location                     = azurerm_resource_group.resource_group[local.resource_group_name].location,
      name                         = format("%s-%s", item[0], item[1]),
      network_interface_ids        = [azurerm_network_interface.network_interface[format("nic-linux-branch-sdwan-spoke-%s", item[1])].id]
      os_disk_name                 = format("disk-%s%s", item[0], item[1]),
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
    }
  }

  route_tables = {
    "rt-sdwan-clients" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "rt-sdwan-clients"
    }
  }

  routes = {
    "udr-default" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                   = "udr-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = "172.16.0.70"
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-sdwan-clients"].name
    }
  }

  subnet_route_table_associations = {
    "snet-branch-sdwan-spoke-1" = {
      subnet_id      = azurerm_subnet.subnet["snet-branch-sdwan-spoke-1"].id
      route_table_id = azurerm_route_table.route_table["rt-sdwan-clients"].id
    }
    "snet-branch-sdwan-spoke-2" = {
      subnet_id      = azurerm_subnet.subnet["snet-branch-sdwan-spoke-2"].id
      route_table_id = azurerm_route_table.route_table["rt-sdwan-clients"].id
    }
  }

  virtual_network_peerings = {
    "branch_fortigate_vnet" = {
      resource_group_name          = "rg-branch-eastus-01"
      name                         = "branch_fortigate_vnet"
      virtual_network_name         = "vnet-branch-eastus-01"
      remote_virtual_network_id    = azurerm_virtual_network.virtual_network[local.virtual_network_name].id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    }
    "branch_sdwan_clients_vnet" = {
      resource_group_name          = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                         = "branch_sdwan_clients_vnet"
      virtual_network_name         = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      remote_virtual_network_id    = "/subscriptions/b7f5408c-0067-47b3-9feb-b79fd9e9fb83/resourceGroups/rg-branch-eastus-01/providers/Microsoft.Network/virtualNetworks/vnet-branch-eastus-01"
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    }

  }

  # Linux VM Image and Size
  linux_vm_image = {
    size      = "Standard_F2"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}