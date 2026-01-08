
variable "all_pools" {
  type    = set(string)
  default = ["os-isos", "vm-templates", "vm-images"]
  description ="The pools required for the build."
}

