resource "random_string" "string" {
  length  = 30
  special = false
}

output "random_string" {
  value = var.enable_output ? random_string.string.result : null
}