resource "fortios_firewall_vip" "firewall_vip_fgt-0" {
  for_each = local.firewall_vips

  provider = fortios.fgt-0

  name             = each.value.name
  extintf          = each.value.extintf
  extip            = each.value.extip
  extport          = each.value.extport
  portforward      = each.value.portforward
  portmapping_type = each.value.portmapping_type
  protocol         = each.value.protocol
  mappedport       = each.value.mappedport
  type             = each.value.type
  mappedip {
    range = each.value.mappedip.range
  }
}

resource "fortios_firewall_vip" "firewall_vip_fgt-1" {
  for_each = local.firewall_vips

  provider = fortios.fgt-1

  name             = each.value.name
  extintf          = each.value.extintf
  extip            = each.value.extip
  extport          = each.value.extport
  portforward      = each.value.portforward
  portmapping_type = each.value.portmapping_type
  protocol         = each.value.protocol
  mappedport       = each.value.mappedport
  type             = each.value.type
  mappedip {
    range = each.value.mappedip.range
  }
}