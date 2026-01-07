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
## Cloud-init seed ISO.
resource "libvirt_cloudinit_disk" "alpine_seed" {

  for_each = var.all_vms

  name = "alpine-cloudinit"

  user_data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        root:password
      expire: false

    ssh_pwauth: true
    #ssh_pwauth: false

    packages:
      - openssh-server

    users:
      - name: jean
        shell: /bin/sh
        lock_passwd: false
        plain_text_passwd: password

      - name: foobar
        shell: /bin/sh
        lock_passwd: false
        plain_text_passwd: foobar



      - name: ansible
        gecos: Ansible User
        groups: users,admin,wheel
        sudo: "ALL=(ALL) NOPASSWD:ALL"
        shell: /bin/bash
        lock_passwd: true
        ssh_authorized_keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRCJCQ1UD9QslWDSw5Pwsvba0Wsf1pO4how5BtNaZn0xLZpTq2nqFEJshUkd/zCWF7DWyhmNphQ8c+U+wcmdNVcg2pI1kPxq0VZzBfZ7cDwhjgeLsIvTXvU+HVRtsXh4c5FlUXpRjf/x+a3vqFRvNsRd1DE+5ZqQHbOVbnsStk3PZppaByMg+AZZMx56OUk2pZCgvpCwj6LIixqwuxNKPxmJf45RyOsPUXwCwkq9UD4me5jksTPPkt3oeUWw1ZSSF8F/141moWsGxSnd5NxCbPUWGoRfYcHc865E70nN4WrZkM7RFI/s5mvQtuj8dRL67JUEwvdvEDO0EBz21FV/iOracXd2omlTUSK+wYrWGtiwQwEgr4r5bimxDKy9L8UlaJZ+ONhLTP8ecTHYkaU1C75sLX9ZYd5YtqjiNGsNF+wdW6WrXrQiWeyrGK7ZwbA7lagSxIa7yeqnKDjdkcJvQXCYGLM9AMBKWeJaOpwqZ+dOunMDLd5VZrDCU2lpCSJ1M="




    timezone: UTC
  EOF

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
## Upload the cloud-init ISO into the pool.
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
