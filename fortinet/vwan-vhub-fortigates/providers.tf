terraform {
  required_providers {
    fortios = {
      source = "fortinetdev/fortios"
    }
  }
  required_version = ">= 1.0.0"
}

provider "fortios" {
  hostname = var.vhub_fortigates["fgt-0"].hostname
  token    = var.vhub_fortigates["fgt-0"].token
  insecure = var.vhub_fortigates["fgt-0"].insecure
  alias    = "fgt-0"
}

provider "fortios" {
  hostname = var.vhub_fortigates["fgt-1"].hostname
  token    = var.vhub_fortigates["fgt-1"].token
  insecure = var.vhub_fortigates["fgt-1"].insecure
  alias    = "fgt-1"
}