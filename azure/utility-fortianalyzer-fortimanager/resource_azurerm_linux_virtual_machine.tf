resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  for_each = local.linux_virtual_machines

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
  size = each.value.size

  network_interface_ids = each.value.network_interface_ids

  identity {
    type = each.value.identity_identity
  }

  source_image_reference {
    publisher = each.value.source_image_reference_publisher
    offer     = each.value.source_image_reference_offer
    sku       = each.value.source_image_reference_sku
    version   = each.value.source_image_reference_version
  }

  plan {
    publisher = each.value.plan_publisher
    product   = each.value.plan_product
    name      = each.value.plan_name
  }

  os_disk {
    name                 = each.value.os_disk_name
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }

  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false
  custom_data                     = each.value.custom_data

  boot_diagnostics {
  }
}

output "linux_virtual_machines" {
  value     = var.enable_output ? azurerm_linux_virtual_machine.linux_virtual_machine[*] : null
  sensitive = true
}
