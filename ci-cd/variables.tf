
#Be sure to update 'undefine.sh' if you add more VMs
variable "all_vms"{
  type = map(object({
                    name     = string
                    sof_mem  = string
                    sof_disk = string
                    network  = string
                  }))

  default ={
            jumpbox = {
              name    : "jumpbox"
              sof_mem : "0"
              sof_disk: "0"
              network : "outer-network"
            },
            vault = {
              name    : "vault"
              sof_mem : "0"
              sof_disk: "0"
              network : "outer-network"
            },
            ns1 = {
              name    : "ns1"
              sof_mem : "0"
              sof_disk: "0"
              network : "outer-network"
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
