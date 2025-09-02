data "azurerm_resource_group" "resource_group" {
  name = var.managed_resource_group_name

  depends_on = [azapi_resource.resource]
}

output "managed_resource_group_name" {
  value = data.azurerm_resource_group.resource_group.name
}