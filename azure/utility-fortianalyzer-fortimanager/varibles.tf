variable "enable_output" {
  description = "Enable/Disable output"
  default     = true
}

variable "username" {
  description = "Username for the Fortinet VMs"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Password for the Fortinet VMs"
  type        = string
  sensitive   = true
}

variable "fortiflexvm_program_serial_number" {
  description = "FortiFlexVM Program Serial Number"
  type        = string
  default     = ""
}
variable "fortiflexvm_account_id" {
  description = "FortiFlexVM Account ID"
  type        = string
  default     = ""
}

variable "faz_serial" {
  description = "FortiAnalyzer Serial Number"
  type        = string
  default     = ""
}

variable "fmg_serial" {
  description = "FortiManager Serial Number"
  type        = string
  default     = ""
}
