
## Basic pool (Note that 3 pools are constructed.)
#resource "libvirt_pool" "basic" {
#  for_each = toset(["os-isos", "vm-ssds", "vm-images"])
#  name = "${each.value}-pool"
#  type = "dir"
#  # source = {
#  #    host = "localhost" 
#  #   dir = "/scratch/scratch-pool" 
#  # }
#  target = {
#    path = "/scratch/${each.value}-pool"
#  }
#}

## Volume from HTTP URL upload
#resource "libvirt_volume" "alpine_base" {
#  name = "alpine-3.22.2.qcow2"
#  pool = libvirt_pool.basic["vm-images"].name
#  #pool = libvirt_pool.default.name
#  #format = "qcow2"
#  # capacity is automatically computed from Content-Length header
#
#  create = {
#    content = {
#      url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.2-x86_64-bios-cloudinit-r0.qcow2"
#    }
#  }
#}

## Volume of prebuilt images
#resource "libvirt_volume" "alpine_images" {
#
##  for_each = var.all_images
#
#  name = "${each.value.name}.qcow2"
#  pool = libvirt_pool.basic["vm-images"].name
#  #format = "qcow2"
#
#  create = {
#    content = {
#      url = "${each.value.url}"
#    }
#  }
#}

## Volumes of Turkey ISOs
#resource "libvirt_volume" "ISOs" {
#  
#  for_each = var.all_isos
#
#  name = "${each.value.name}.qcow2"
#  pool = libvirt_pool.basic["os-isos"].name
#
#  #pool = libvirt_pool.default.name
#  #format = "qcow2"
#  
#  #capacity = 1073741824
#
#  create = {
#    content = {
#      url = "${each.value.url}"
#    }
#  }
#}




## Basic pool
#resource "libvirt_pool" "default" {
#  name = "scratch-pool"
#  type = "dir"
#  # source = {
#  #    host = "localhost" 
#  #   dir = "/scratch/scratch-pool" 
#  # }
#  target = {
#    path = "/scratch/scratch-pool"
#  }
#}


## Writable copy-on-write layer for the VM.
resource "libvirt_volume" "vm_disk" {

  for_each = var.all_vms

  name = "${each.value.name}.qcow2"

  #pool      = libvirt_pool.basic["vm-ssds"].name
  pool      = "vm-ssds"
  #type     = "file"
  capacity  = 10737418240
  #capacity = 2147483648
  #capacity  = 10
  #capacity_unit = "GiB"
  target = {
    format = {
      type   = "qcow2"
    }
  }
  backing_store = {
    path   =  libvirt_volume.alpine_images["${each.value.image}"].path
    format = {
      type = "qcow2"
      #type = "raw"
      #type = contains(keys(libvirt_volume.ISOs), "${each.value.image}") ?  "raw":"qcow2"
    }
  }
  /*
  backing_store = {
    path = contains(keys(libvirt_volume.ISOs), "${each.value.image}") ?  libvirt_volume.ISOs["${each.value.image}"].path: libvirt_volume.alpine_images["${each.value.image}"].path
    format = {
      #type = "qcow2"
      #type = "raw"
      type = contains(keys(libvirt_volume.ISOs), "${each.value.image}") ?  "raw":"qcow2"
    }
  }
  */
}


