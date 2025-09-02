resource "fortiflexvm_entitlements_vm_token" "entitlements_vm_token" {
  for_each = local.license_type == "flex" ? data.fortiflexvm_entitlements_list.entitlements_list : {}

  config_id        = data.fortiflexvm_entitlements_list.entitlements_list[each.key].entitlements[0].config_id
  serial_number    = data.fortiflexvm_entitlements_list.entitlements_list[each.key].entitlements[0].serial_number
  regenerate_token = true
}

output "entitlements_vm_token" {
  value = var.enable_output ? fortiflexvm_entitlements_vm_token.entitlements_vm_token : null
}