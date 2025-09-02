resource "azapi_resource" "resource" {
  type      = "Microsoft.Solutions/applications@2021-07-01"
  name      = "ftnt-mih-vwan-fgt"
  parent_id = azurerm_resource_group.resource_group[local.vwan_resource_group_name].id
  location  = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.user_assigned_identity["id-ftnt-mih"].id
    ]
  }
  body = {
    kind = "MarketPlace",
    plan = {
      name      = "fortigate-managedvwan"
      product   = "fortigate_vwan_nva"
      publisher = "fortinet"
      version   = "7.4.800250826"         # Do not change unless provided a new version by Fortinet
      # version   = "7.4.700250513".      # Previous version, updated 08/28/2025
    },
    properties = {
      managedResourceGroupId = "${data.azurerm_subscription.subscription.id}/resourcegroups/${var.managed_resource_group_name}",
      parameters = {
        adminUsername = {
          value = var.admin_username
        }
        adminPassword = {
          value = var.admin_password
        }
        fortiGateNamePrefix = {
          value = "ftntmih"
        }
        vwandeploymentSKU = {
          value = "sdfw-payg" # Options are: "sdfw-payg", "sdfw-byol", "ngfw-payg", "ngfw-byol"
        }
        managedApplicationPlan = {
          value = "fortigate-managedvwan"
        }
        vwandeploymentType = {
          value = "sdfw" # Options are: "sdfw" or "ngfw"
        }
        fortiGateImageVersion = {
          value = "7.4.7" # Options are: "7.4.7", "7.4.8" as of 09/02/2025
        }
        hubId = {
          value = azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].id
        }
        fortiGateASN = {
          value = "64512"
        }
        tags = {
          value = {}
        }
        scaleUnit = {
          value = "2"
        }
        hubRouters = {
          value = [
            azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].virtual_router_ips[0],
            azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].virtual_router_ips[1]
          ]
        }
        hubASN = {
          value = tostring(azurerm_virtual_hub.virtual_hub["vhub-eastus-1"].virtual_router_asn)
        }
        location = {
          value = azurerm_resource_group.resource_group[local.vwan_resource_group_name].location,
        }
        fortiManagerIP = {
          value = ""
        }
        fortiManagerSerial = {
          value = ""
        }
        internetInboundCheck = {
          value = true
        }
        slbpiprg = {
          value = azurerm_public_ip.public_ip["pip-elb"].resource_group_name
        }
        slbpipname = {
          value = azurerm_public_ip.public_ip["pip-elb"].name
        }
        slbPIpNewOrExisting = {
          value = "existing"
        }
        slbpublicIpDns = {
          value = ""
        }
        slbpublicIpSku = {
          value = "Standard"
        }
      }
    }
  }
}