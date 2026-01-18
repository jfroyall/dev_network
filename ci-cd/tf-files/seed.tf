## A null resource 
#resource "terraform_data" "shutdowner" {
#  # iterate with for_each over Vms list ( my *.tf file creates VMs from list)
#  #for_each = toset(local.vm_common_list_count)
#  #triggers = { trigger = var.vm_condition_poweron }
#
#  triggers_replace  = [
#    var.vm_condition_poweron
#  ]
#  provisioner "local-exec" {
#    #command = var.vm_condition_poweron?"echo 'do nothing'":"echo 'do less'"
#    command = var.vm_condition_poweron?"echo 'do nothing'":"undefine.sh"
#    #command = var.vm_condition_poweron?"echo 'do nothing'":"virsh -c qemu:///system shutdown alpine-vm \&\& virsh -c qemu:///system undefine alpine-vm"
#    #command = var.vm_condition_poweron?"echo 'do nothing'":"virsh -c qemu:///system shutdown ${each.value}"
#  }
#}
#
#

#
# Cloud-init seed ISO.
resource "libvirt_cloudinit_disk" "alpine_seed" {

  for_each = var.all_vms

  name = "alpine-cloudinit"

  #user_data = file("user-data.yaml")
  user_data = templatefile(each.value.user_data,  { host_name = "${each.value.name}", domain_name=libvirt_network.outer.domain.name})

  meta_data = <<-EOF
    instance-id: ${each.value.name}
    local-hostname: ${each.value.name}
  EOF

  network_config = <<-EOF
    version: 2
    ethernets:
      eth0:
        dhcp4: true
  EOF
}
#
# Upload the cloud-init ISO into the pool.
resource "libvirt_volume" "alpine_seed_volume" {

  for_each = var.all_vms

  name = "alpine-cloudinit-${each.value.name}.iso"
  #pool = "default"
  pool = libvirt_pool.basic["os-isos"].name

  create = {
    content = {
      url = libvirt_cloudinit_disk.alpine_seed[each.value.name].path
    }
  }
}
#
#
#
## Basic volume
##resource "libvirt_volume" "example" {
##  name = "example.qcow2"
##  #pool     = "${libvirt_pool.default}.name"
##  pool     = "default"
##  capacity = 1073741824 # 1 GB
##  format   = "qcow2"
##}
##
##resource "libvirt_volume" "vm-qcow2" {
##  name   = "guest.qcow2"
##  pool   = libvirt_pool.vmpool.name
##  source = "${path.module}/sources/guest.qcow2"
##  format = "qcow2"
##}
### Volume with backing store
##resource "libvirt_volume" "base" {
##  name     = "base.qcow2"
##  pool     = "default"
##  capacity = 10737418240
##  format   = "qcow2"
##}
##
##resource "libvirt_volume" "overlay" {
##  name     = "overlay.qcow2"
##  pool     = "default"
##  capacity = 10737418240
##
##  backing_store = {
##    path   = libvirt_volume.base.path
##    format = "qcow2"
##  }
##}
##
### Volume from HTTP URL upload
##resource "libvirt_volume" "ubuntu_base" {
##  name   = "ubuntu-22.04.qcow2"
##  pool   = "default"
##  format = "qcow2"
##
##  create = {
##    content = {
##      url = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
##    }
##  }
##  # capacity is automatically computed from Content-Length header
##}
##
### Volume from local file upload
##resource "libvirt_volume" "from_local" {
##  name   = "custom-image.qcow2"
##  pool   = "default"
##  format = "qcow2"
##
##  create = {
##    content = {
##      url = "/path/to/local/image.qcow2"
##      # or: url = "file:///path/to/local/image.qcow2"
##    }
##  }
##  # capacity is automatically computed from file size
##}
#
#
