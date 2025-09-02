data "fortiflexvm_entitlements_list" "entitlements_list" {
  for_each = local.license_type == "flex" ? local.fortinet_serials : {}

  account_id            = var.fortiflexvm_account_id
  program_serial_number = var.fortiflexvm_program_serial_number

  serial_number = each.value.serial_number
}
output "entitlements_list" {
  value = data.fortiflexvm_entitlements_list.entitlements_list
}
