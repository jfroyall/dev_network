
# Volume from HTTP URL upload
#resource "libvirt_volume" "alpine_base" {
#  name = format("%s.qcow2", var.all_images["alpine"].name)
#  pool = libvirt_pool.basic["vm-templates"].name
#  #format = "qcow2"
#  # capacity is automatically computed from Content-Length header
#
#  create = {
#    content = {
#      url = var.all_images["alpine"].url
#    }
#  }
#}

## Volume for a prebuilt image (used as a backing store for vm_disk)
resource "libvirt_volume" "alpine_images" {

  for_each = var.all_images

  name = "${each.value.name}.qcow2"
  pool = libvirt_pool.basic["vm-images"].name
  #format = "qcow2"

  create = {
    content = {
      url = "${each.value.url}"
    }
  }
}

# Writable copy-on-write layer for each VM/(libvirt domain).
resource "libvirt_volume" "vm_disk" {

  for_each = local.all_cow_disks

  name = "${each.key}.qcow2"

  pool      = libvirt_pool.basic["vm-images"].name
  #type     = "file"
  capacity  = "${each.value.sof_disk}"
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
}


## Volumes of Turnkey ISOs
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


