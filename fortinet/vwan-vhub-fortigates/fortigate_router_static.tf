resource "fortios_router_static" "route_static_fgt-0" {

  for_each = local.static_routes

  provider = fortios.fgt-0

  dst      = each.value.dst
  gateway  = each.value.gateway
  device   = each.value.device
  distance = each.value.distance
  priority = each.value.priority
  status   = each.value.status
}

resource "fortios_router_static" "route_static_fgt-1" {

  for_each = local.static_routes

  provider = fortios.fgt-1

  dst      = each.value.dst
  gateway  = each.value.gateway
  device   = each.value.device
  distance = each.value.distance
  priority = each.value.priority
  status   = each.value.status
}