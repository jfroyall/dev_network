
#The images required.  Note that the index is the name of the VM.
variable "all_images"{
  type = map(object({
                    name = string
                    url  = string
                  }))
  default ={
            alpine = {
              name = "alpine-3.23"
              url = "https://dl-cdn.alpinelinux.org/v3.23/releases/cloud/generic_alpine-3.23.0-x86_64-bios-cloudinit-r0.qcow2"
              #url = "https://dl-cdn.alpinelinux.org/v3.23/releases/cloud/generic_alpine-3.23.0-x86_64-uefi-cloudinit-r0.qcow2"
            },
            /*
            vault = {
              name: "core-turnkey"
              url : "file:///scratch/vault.qcow2"
            },
            jumpbox = {
              name: "jumpbox"
              url : "file:///scratch/vm-images/nginx.qcow2"
            },
            nginx = {
              name: "nginx"
              url : "file:///scratch/vm-images/nginx.qcow2"
            },
            jenkins = {
              name: "jenkins"
              url : "file:///scratch/vm-images/jenkins.qcow2"
            },
            vault = {
              name: "vault"
              url : "file:///scratch/vm-images/vault.qcow2"
            },
            my-sql = {
              name: "my-sql"
              url : "file:///scratch/vm-images/my-sql.qcow2"
            },
            #core = {
            #  name: "core-turnkey"
            #  url : "file:///scratch/vm-images/jenkins.qcow2"
            #},
            */
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
#            redmine = {
#              name: "redmine"
#              url : "file:///scratch/turnkey-redmine-18.1-bookworm-amd64.iso"
#            },
           }
  description ="The ISOs required for the build."
}


## ## ## ## ## ## ## ## ## ##
##  ------   Important DO NOT add redmine until later!
##  ------   Important DO NOT add redmine until later!
## ## ## ## ## ## ## ## ## ##

#Be sure to update 'undefine.sh' if you add more VMs
variable "all_vms"{
  type = map(object({
                    name     = string
                    sof_mem  = number
                    sof_disk = number
                    image    = string
                    network  = string
                  }))

  default ={
            /*
            */
            jumpbox = {
              name    : "jumpbox"
              sof_mem : 2*1024*1024*1024
              sof_disk: 4*1024*1024*1024
              image   : "alpine"
              network : "outer-network"
            },
            vault = {
              name    : "vault"
              sof_mem : 2*1024*1024*1024
              sof_disk: 4*1024*1024*10240
              image   : "alpine"
              network : "outer-network"
            },
            nginx = {
              name    : "nginx"
              sof_mem : 2*1024*1024*10240
              sof_disk: 4*1024*1024*10240
              image   : "alpine"
              network : "outer-network"
            },
            /*
            */
            /*
            ns1 = {
              name    : "ns1"
              sof_mem : 4*1024*1024*10240
              sof_disk: 10*1024*1024*10240
              image   : "core"
              network : "outer-network"
            },
            my-sql = {
              name    : "my-sql"
              sof_mem : 4*1024*1024*10240
              sof_disk: 20*1024*1024*10240
              image   : "my-sql"
              network : "inner-network"
            },
            jenkins = {
              name    : "jenkins"
              sof_mem : 4*1024*1024*10240
              sof_disk: 10*1024*1024*10240
              image   : "jenkins"
              network : "inner-network"
            },
           */
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
