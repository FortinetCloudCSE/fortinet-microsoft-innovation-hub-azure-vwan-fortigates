resource "azurerm_virtual_hub_routing_intent" "virtual_hub_routing_intent" {
  for_each = local.virtual_hub_routing_intents

  name = each.value.name

  virtual_hub_id = each.value.virtual_hub_id

  dynamic "routing_policy" {
    for_each = each.value.routing_policys
    content {
      name         = routing_policy.value.name
      destinations = routing_policy.value.destinations
      next_hop     = routing_policy.value.next_hop
    }
  }
}

output "virtual_hub_routing_intent" {
  value = azurerm_virtual_hub_routing_intent.virtual_hub_routing_intent[*]
} 