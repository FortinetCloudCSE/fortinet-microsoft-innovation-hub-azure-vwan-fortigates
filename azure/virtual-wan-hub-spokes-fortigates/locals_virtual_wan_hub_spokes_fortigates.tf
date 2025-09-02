locals {

  # Phase two is when we create the VMs and VPN gateways
  phase_two = true
  phase_three = false

  admin_username = var.admin_username
  admin_password = var.admin_password

  vwan_resource_group_name     = "rg-ftnt-mih-vwan"
  vwan_resource_group_location = "eastus"

  spokes_resource_group_name     = "rg-ftnt-mih-vwan-spokes"
  spokes_resource_group_location = "eastus"

  resource_groups = {
    (local.vwan_resource_group_name) = {
      name     = local.vwan_resource_group_name,
      location = local.vwan_resource_group_location
    }
    (local.spokes_resource_group_name) = {
      name     = local.spokes_resource_group_name,
      location = local.spokes_resource_group_location
    }
  }

  virtual_wans = {
    "vwan-ftnt-mih" = {
      resource_group_name = azurerm_resource_group.resource_group[local.vwan_resource_group_name].name,
      location            = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location,
      name                = "vwan-ftnt-mih",
      type                = "Standard"
    }

  }

  virtual_hubs = {
    "vhub-eastus-1" = {
      resource_group_name                    = azurerm_resource_group.resource_group[local.vwan_resource_group_name].name,
      location                               = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location,
      name                                   = "vhub-eastus-1",
      address_prefix                         = "10.100.0.0/16",
      virtual_wan_id                         = azurerm_virtual_wan.virtual_vwan["vwan-ftnt-mih"].id
      sku                                    = "Standard"
      hub_routing_preference                 = "ASPath"
      virtual_router_auto_scale_min_capacity = 2
    }
  }

  vpn_gateways = {
    "vpn-gateway-eastus-1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.vwan_resource_group_name].name,
      location            = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location,

      name           = "vpn-gateway-eastus",
      virtual_hub_id = azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].id,
      scale_units    = 1
    }
  }

  user_assigned_identities = {
    "id-ftnt-mih" = {
      resource_group_name = azurerm_resource_group.resource_group[local.vwan_resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location

      name = "id-ftnt-mih"
    }
  }
  role_definition_names = ["Network Contributor"]

  # Create a list of Managed Identities and Roles
  user_assigned_identity_roles_list = setproduct(values(local.user_assigned_identities), local.role_definition_names)

  # Create a map of Role Scope, Role and Managed Identity (principal_id) from the list
  role_assignments = {
    for item in local.user_assigned_identity_roles_list :
    format("%s-%s", item[0]["name"], item[1]) => {
      user_assigned_identity_name = item[0]["name"],
      scope                       = data.azurerm_subscription.subscription.id,
      role_definition_name        = item[1],
      principal_id                = azurerm_user_assigned_identity.user_assigned_identity[item[0]["name"]].principal_id,
    }
  }

  # Create a map of virtual networks from Resource Groups and desired VNet count
  virtual_network_list = setproduct(["vnet-spoke-"], ["1", "2"])
  virtual_networks = {
    for item in local.virtual_network_list :
    format("%s%s", item[0], item[1]) => {
      resource_group_name = azurerm_resource_group.resource_group[local.spokes_resource_group_name].name,
      location            = azurerm_resource_group.resource_group[local.spokes_resource_group_name].location,
      name                = format("%s%s", item[0], item[1]),
      address_space       = [format("192.168.%s0.0/24", item[1])]
    }
  }

  # Create a map of subnets from Resource Groups and desired Subnet count
  subnet_list = setproduct(["snet-spoke-"], ["1", "2"])
  subnets = {
    for item in local.subnet_list :
    format("%s%s", item[0], item[1]) => {
      resource_group_name  = azurerm_resource_group.resource_group[local.spokes_resource_group_name].name,
      location             = azurerm_resource_group.resource_group[local.spokes_resource_group_name].location,
      name                 = format("%s%s", item[0], item[1]),
      address_prefixes     = [format("192.168.%s0.0/24", item[1])],
      virtual_network_name = azurerm_virtual_network.virtual_network[format("vnet-spoke-%s", item[1])].name
    }
  }

  # Create a map of linux VM NICs from Resource Groups and desired VM Nic count
  network_interface_list = setproduct(["nic-linux-spoke"], ["1", "2"])
  network_interfaces = {
    for item in local.network_interface_list :
    format("%s-%s", item[0], item[1]) => {
      resource_group_name = azurerm_resource_group.resource_group[local.spokes_resource_group_name].name,
      location            = azurerm_resource_group.resource_group[local.spokes_resource_group_name].location,
      name                = format("%s-%s", item[0], item[1])
      ip_configuration = {
        name                          = "ipconfig",
        subnet_id                     = azurerm_subnet.subnet[format("snet-spoke-%s", item[1])].id,
        private_ip_address_allocation = "Dynamic"
      }
    }
  }

  # Create a map of linux VMs from Resource Groups and desired VM count
  linux_virtual_machine_list = setproduct(["vm-linux-spoke"], ["1", "2"])
  linux_virtual_machines = {
    for item in local.linux_virtual_machine_list :
    format("%s-%s", item[0], item[1]) => {
      resource_group_name          = azurerm_resource_group.resource_group[local.spokes_resource_group_name].name,
      location                     = azurerm_resource_group.resource_group[local.spokes_resource_group_name].location,
      name                         = format("%s-%s", item[0], item[1]),
      network_interface_ids        = [azurerm_network_interface.network_interface[format("nic-linux-spoke-%s", item[1])].id]
      os_disk_name                 = format("disk-%s%s", item[0], item[1]),
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"
    }
  }

  virtual_hub_connections = {
    vhub-eastus-1 = {
      name                      = "vhub-eastus-1-to-spoke-1",
      virtual_hub_id            = azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].id,
      remote_virtual_network_id = azurerm_virtual_network.virtual_network["vnet-spoke-1"].id
      internet_security_enabled = true

    }
    vhub-eastus-2 = {
      name                      = "vhub-eastus-1-to-spoke-2",
      virtual_hub_id            = azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].id,
      remote_virtual_network_id = azurerm_virtual_network.virtual_network["vnet-spoke-2"].id
      internet_security_enabled = true
    }
  }

  public_ips = {
    "pip-elb" = {
      resource_group_name = azurerm_resource_group.resource_group[local.vwan_resource_group_name].name,
      location            = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location,

      name              = "pip-elb"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  virtual_hub_routing_intents = {
    "vhub-eastus-1" = {
      name           = "routing-intent"
      virtual_hub_id = azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].id
      routing_policys = [
        {
          name         = "PrivateTrafficPolicy"
          destinations = ["PrivateTraffic"]
          next_hop     = data.azapi_resource_list.resource_list.output.value[0].id
        },
        {
          name         = "InternetTrafficPolicy"
          destinations = ["Internet"]
          next_hop     = data.azapi_resource_list.resource_list.output.value[0].id
        }
      ]
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
