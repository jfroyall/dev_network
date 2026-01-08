

#The images required.  Note that the index is the name of the VM.
variable "all_images"{
  type = map(object({
                    name = string
                    url  = string
                  }))
  description ="The images required for the build."
}

#Be sure to update 'undefine.sh' if you add more VMs
variable "all_vms"{
  type = map(object({
                    name     = string
                    sof_mem  = number
                    sof_disk = number
                    image    = string
                    network  = string
                  }))

  description ="The set of all VMs which will be created."
}

