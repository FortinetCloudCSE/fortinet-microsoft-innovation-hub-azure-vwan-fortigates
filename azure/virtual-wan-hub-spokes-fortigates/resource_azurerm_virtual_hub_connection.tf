
resource "azurerm_virtual_hub_connection" "virtual_hub_connection" {
  for_each = local.virtual_hub_connections

  name                      = each.value.name
  virtual_hub_id            = each.value.virtual_hub_id
  remote_virtual_network_id = each.value.remote_virtual_network_id
  internet_security_enabled = each.value.internet_security_enabled

}

output "virtual_hub_connections" {
  value     = var.enable_output ? azurerm_virtual_hub_connection.virtual_hub_connection[*] : null
  sensitive = true
}