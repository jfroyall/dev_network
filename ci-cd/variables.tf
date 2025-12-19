
#The images required.  Note that the index is the name of the VM.
variable "all_images"{
  type = map(object({
                    name = string
                    url  = string
                  }))
  default ={
#            redmine = {
#              name: "redmine"
#              url : "https://www.turnkeylinux.org/download?file=turnkey-redmine-18.1-bookworm-amd64.iso"
#            },
#            jenkins = {
#              name: "jenkins"
#              url : "https://www.turnkeylinux.org/download?file=turnkey-jenkins-18.1-bookworm-amd64.iso"
#            },
#            core = {
#              name: "core-turnkey"
#              url : "https://www.turnkeylinux.org/docs/builds#vm-vmdk"
#            },
            alpine = {
              name = "alpine-3.22.2"
              url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.2-x86_64-bios-cloudinit-r0.qcow2"
            },
           }
  description ="The images required for the build."
}

#The ISOs required.  Note that the index is the name of the VM.
variable "all_isos"{
  type = map(object({
                    name = string
                    url  = string
                  }))
  default ={
            redmine = {
              name: "redmine"
              url : "file:///scratch/turnkey-redmine-18.1-bookworm-amd64.iso"
            },
            jenkins = {
              name: "jenkins"
              url : "file:///scratch/turnkey-jenkins-18.1-bookworm-amd64.iso"
            },
            core = {
              name: "core-turnkey"
              url : "file:///scratch/turnkey-core-18.1-bookworm-amd64.iso"
            },
            nginx = {
              name: "nginx"
              url : "file:///scratch/turnkey-nginx-php-fastcgi-18.0-bookworm-amd64.iso"
            },
           }
  description ="The ISOs required for the build."
}


#Be sure to update 'undefine.sh' if you add more VMs
variable "all_vms"{
  type = map(object({
                    name     = string
                    sof_mem  = string
                    sof_disk = string
                    image    = string
                    network  = string
                  }))

  default ={
            jumpbox = {
              name    : "jumpbox"
              sof_mem : "0"
              sof_disk: "0"
              image   : "alpine"
              network : "outer-network"
            },
            vault = {
              name    : "vault"
              sof_mem : "0"
              sof_disk: "0"
              image   : "core"
              network : "outer-network"
            },
            ns1 = {
              name    : "ns1"
              sof_mem : "0"
              sof_disk: "0"
              image   : "core"
              network : "outer-network"
            },
            jenkins = {
              name    : "jenkins"
              sof_mem : "0"
              sof_disk: "0"
              image   : "jenkins"
              network : "inner-network"
            },
           }
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

#variable "db_disk_size" {
# type        = number
# description = "Disk size for the API database"
# default     = 100
#}
#
#variable "db_password" {
# type        = string
# description = "Database password"
# sensitive   = true
#}
#
