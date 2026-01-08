
## Volume from HTTP URL upload
resource "libvirt_volume" "alpine_base" {
  name = format("%s.qcow2", var.all_images["alpine"].name)
  #pool = libvirt_pool.basic["vm-templates"].name
  pool = "vm-templates"
  #format = "qcow2"
  # capacity is automatically computed from Content-Length header

  create = {
    content = {
      url = var.all_images["alpine"].url
    }
  }
}

## Volume of prebuilt images
resource "libvirt_volume" "alpine_images" {

  for_each = var.all_images

  name = "${each.value.name}.qcow2"
  #pool = libvirt_pool.basic["vm-images"].name
  pool = "vm-images"
  #format = "qcow2"

  create = {
    content = {
      url = "${each.value.url}"
    }
  }
}

# Writable copy-on-write layer for each VM.
resource "libvirt_volume" "vm_disk" {

  for_each = var.all_vms

  name = "${each.value.name}.qcow2"

  #pool      = libvirt_pool.basic["vm-images"].name
  pool      = "vm-images"
  #type     = "file"
  capacity  = "${each.value.sof_disk}"
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


