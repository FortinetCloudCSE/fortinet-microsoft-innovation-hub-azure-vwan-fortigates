variable "enable_output" {
  description = "Enable/Disable output"
  default     = true
}

variable "vhub_fortigates" {
  type = map(object({
    hostname = string
    token    = string
    insecure = bool
    alias    = string
  }))
  default = {}
}