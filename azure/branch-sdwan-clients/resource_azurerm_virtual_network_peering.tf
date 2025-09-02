resource "azurerm_virtual_network_peering" "virtual_network_peering" {
  for_each = local.virtual_network_peerings

  resource_group_name = each.value.resource_group_name

  name                         = each.value.name
  virtual_network_name         = each.value.virtual_network_name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
}

output "virtual_network_peerings" {
  value = var.enable_output ? azurerm_virtual_network_peering.virtual_network_peering[*] : []
}