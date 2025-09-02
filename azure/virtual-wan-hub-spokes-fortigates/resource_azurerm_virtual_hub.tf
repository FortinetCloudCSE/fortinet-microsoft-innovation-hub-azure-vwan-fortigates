resource "azurerm_virtual_hub" "virtual_hub" {
  for_each = local.virtual_hubs

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name                                   = each.value.name
  address_prefix                         = each.value.address_prefix
  virtual_wan_id                         = each.value.virtual_wan_id
  sku                                    = each.value.sku
  hub_routing_preference                 = each.value.hub_routing_preference
  virtual_router_auto_scale_min_capacity = each.value.virtual_router_auto_scale_min_capacity
}

output "virtual_hubs" {
  value = var.enable_output ? azurerm_virtual_hub.virtual_hub[*] : null
}
