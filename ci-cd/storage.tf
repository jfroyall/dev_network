
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

