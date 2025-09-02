output "rg" {
  value = format("%s / %s", azurerm_resource_group.resource_group[local.resource_group_name].name, azurerm_resource_group.resource_group[local.resource_group_name].location)
}

output "faz_ip" {
  value = format("https://%s", azurerm_public_ip.public_ip["pip-faz"].ip_address)
}
output "fmg_ip" {
  value = format("https://%s", azurerm_public_ip.public_ip["pip-fmg"].ip_address)
}

output "creds" {
  value     = format("username: %s / password: %s", local.username, local.password)
  sensitive = true
}
