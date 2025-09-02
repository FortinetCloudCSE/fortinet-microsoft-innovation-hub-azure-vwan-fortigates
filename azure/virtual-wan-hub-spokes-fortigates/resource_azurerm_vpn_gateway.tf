resource "azurerm_vpn_gateway" "vpn_gateway" {
  for_each = local.phase_three ? local.vpn_gateways : {} # Only create VPN gateways in phase two 

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name           = each.value.name
  virtual_hub_id = each.value.virtual_hub_id
  scale_unit     = each.value.scale_units
}
output "vpn_gateways" {
  value     = var.enable_output ? azurerm_vpn_gateway.vpn_gateway[*] : null
  sensitive = true
}