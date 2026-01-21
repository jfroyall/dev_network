
variable "scratch_dir" {
  type = string
  #default = "/Users/jean/Scratch"
  default = "/scratch"
  description ="The scratch directory."
}

variable "all_user_data" {
  type = map(string)
  default ={
    standard = "user-data.yaml.tpl",
    ansible  = "ansible-user-data.yaml.tpl"
  }
}
variable "all_pools" {
  type    = set(string)
  default = ["os-isos", "vm-templates", "vm-images"]
  description ="The pools required for the build."
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


#The images required.  Note that the index is the name of the VM.
variable "all_images"{
  type = map(object({
                    name = string
                    url  = string
                  }))
  description ="The images required for the build."
}

#The ISOs required.  Note that the index is the name of the VM.
variable "all_isos"{
  type = map(object({
                    name = string
                    url  = string
                  }))
  default ={
#            redmine = {
#              name: "redmine"
#              url : "file:///scratch/turnkey-redmine-18.1-bookworm-amd64.iso"
#            },
           }
  description ="The ISOs required for the build."
}



variable "all_vms"{
  type = map(object({
                    name     = string
                    sof_mem  = number
                    sof_disk = number
                    image    = string
                    network  = string
                    user_data  = string
                  }))

  description ="The set of all VMs which will be created."
}


variable "vm_condition_poweron" {
  description = "Set to true if the instances are defined"
  default = true
}

variable "instance_count" {
  type        = number
  description = "Number of instances to deploy. This application requires at least two instances."
  default     = 2
  validation {
    condition     = var.instance_count > 1
    error_message = "This application requires at least two web instances."
  }
}

variable "web_instance_count" {
  type        = number
  description = "Number of web instances to deploy. This application requires at least two instances."
  default     = 2
  validation {
    condition     = var.web_instance_count > 1
    error_message = "This application requires at least two web instances."
  }
}

