resource "azurerm_virtual_wan" "virtual_vwan" {
  for_each = local.virtual_wans

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
  type = each.value.type
}

output "virtual_wans" {
  value = var.enable_output ? azurerm_virtual_wan.virtual_vwan[*] : null
}
