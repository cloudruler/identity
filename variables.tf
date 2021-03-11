variable "location" {
  type = string
}

# variable "keyvault_admin_spn" {
#   type = list(string)
# }

variable "keyvault_admin_users" {
  type = list(string)
}

variable "generate_keys" {
  type = bool
  default = false
  description = "Use this to regenerate keys. Afterwards, we should remove the state and then run again with this set to false"
}