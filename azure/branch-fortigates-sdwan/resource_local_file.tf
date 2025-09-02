resource "local_file" "file" {
  for_each = local.virtual_machines

  filename = format("configs/fortios_%s.cfg", each.value.name)
  content  = local.virtual_machines[each.key].os_profile_custom_data
}

output "local_files" {
  value     = var.enable_output ? local_file.file[*] : null
  sensitive = true
}