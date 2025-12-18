
## Basic pool
resource "libvirt_pool" "basic" {
  for_each = toset(["os-isos", "vm-ssds", "vm-images"])
  name = "${each.value}-pool"
  type = "dir"
  # source = {
  #    host = "localhost" 
  #   dir = "/scratch/scratch-pool" 
  # }
  target = {
    path = "/scratch/${each.value}-pool"
  }
}

## Volume from HTTP URL upload
resource "libvirt_volume" "alpine_base" {
  name = "alpine-3.22.2.qcow2"
  #pool = libvirt_pool.default.name
  pool = libvirt_pool.basic["vm-images"].name
  #format = "qcow2"

  create = {
    content = {
      url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.2-x86_64-bios-cloudinit-r0.qcow2"
    }
  }
  # capacity is automatically computed from Content-Length header
}




## Basic pool
resource "libvirt_pool" "default" {
  name = "scratch-pool"
  type = "dir"
  # source = {
  #    host = "localhost" 
  #   dir = "/scratch/scratch-pool" 
  # }
  target = {
    path = "/scratch/scratch-pool"
  }
}

#resource "libvirt_pool" "vm" {
#  name        = "vm-pool"
#  type        = "dir"
#  target      = {
#    path = "/scratch/vm-pool"
#  }
#}

#resource "libvirt_pool" "ssd" {
#  name        = "ssd-pool"
#  type        = "dir"
#  target      = {
#    path = "/scratch/ssd-pool"
#  }
#}

