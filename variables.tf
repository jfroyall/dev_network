

#variable "uri" {
#  type = string
#  #default = "/Users/jean/Scratch"
#  #default = "/scratch"
#  description ="The URI to use."
#}
#
#variable "scratch_dir" {
#  type = string
#  #default = "/Users/jean/Scratch"
#  #default = "/scratch"
#  description ="The scratch directory."
#}

variable "platform_ip" {
  type = string
  description ="The IP address of the platform."
  #validation {
  #  condition     = var.dev_host == "papa" || var.dev_host == "mac"
  #  error_message = "The dev_host value must be either \"papa\" or \"mac\"."
  #}
}

variable "platform_dns_name" {
  type = string
  description ="The name of the platform."
  #validation {
  #  condition     = var.dev_host == "papa" || var.dev_host == "mac"
  #  error_message = "The dev_host value must be either \"papa\" or \"mac\"."
  #}
}
variable "dev_host" {
  type = string
  description ="The name of the development host."
  validation {
    condition     = var.dev_host == "papa" || var.dev_host == "mac"
    error_message = "The dev_host value must be either \"papa\" or \"mac\"."
  }
}


variable "nof_vms" {
  type = number
  description = "The number of VMs"
  default = 1
}

variable "always_false" {
  type = bool
  description = "The name of the development host."
  default = false
}


variable "all_branches" {
  type    = set(string)
  default = ["prod", "test", "dev"]
  description ="The git branches (correspond to DNS domains)."
}

#maps a branch to an IP octet
variable "ip_octet"{
  type = map(number)
  default ={
            prod : 16
            test : 17
            dev  : 18
           }
  description ="Maps a branch to an IP octet."
}




