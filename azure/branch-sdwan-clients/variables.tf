variable "enable_output" {
  description = "Enable/Disable output"
  default     = true
}

variable "admin_username" {
  description = "The username for the admin account."
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "The password for the admin account."
  type        = string
  default     = ""
}
