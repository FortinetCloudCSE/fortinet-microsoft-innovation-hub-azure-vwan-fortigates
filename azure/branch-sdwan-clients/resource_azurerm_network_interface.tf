resource "azurerm_network_interface" "network_interface" {
  for_each = local.network_interfaces

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name

  ip_configuration {
    name                          = each.value.ip_configuration.name
    subnet_id                     = each.value.ip_configuration.subnet_id
    private_ip_address_allocation = each.value.ip_configuration.private_ip_address_allocation
  }
}

output "network_interfaces" {
  value = var.enable_output ? azurerm_network_interface.network_interface[*] : null
}
