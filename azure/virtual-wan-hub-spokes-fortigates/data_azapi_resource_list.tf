data "azapi_resource_list" "resource_list" {
  type                   = "Microsoft.Network/networkVirtualAppliances@2023-11-01"
  parent_id              = data.azurerm_resource_group.resource_group.id
  response_export_values = ["*"]

  depends_on = [azapi_resource.resource]
}

output "resource_list" {
  value = data.azapi_resource_list.resource_list.output.value[0].id
}
