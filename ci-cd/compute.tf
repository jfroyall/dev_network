##
## Virtual machine definition.
#resource "libvirt_domain" "alpine" {
#  name   = "alpine-vm"
#  type   = "kvm"
#  memory = 1048576
#  vcpu   = 1
#
#  os = {
#    type    = "hvm"
#    type_arch    = "x86_64"
#    type_machine = "q35"
     #kernel = "/boot/vmlinuz"
     #initrd = "/boot/initrd.img"
     #kernel_args = "console=ttyS0 root=/dev/vda1"
#    #boot_devices = [ {dev = "hd"}, {dev = "network"}]
#  }
#
#  devices = {
#    disks = [
#      {
#        source = {
#          volume = {
#            pool   = libvirt_volume.alpine_disk.pool
#            volume = libvirt_volume.alpine_disk.name
#          }
#        }
#        target = {
#          dev = "vda"
#          bus = "virtio"
#        }
#      },
#      {
#        device = "cdrom"
#        source = {
#          volume = {
#            pool   = libvirt_volume.alpine_seed_volume.pool
#            volume = libvirt_volume.alpine_seed_volume.name
#          }
#        }
#        target = {
#          dev = "sda"
#          bus = "sata"
#        }
#      }
#    ]
#
#    interfaces = [
#      {
#        type  = "network"
#        model = {
#          type = "virtio"
#        }
#        source = {
#          network = {
#            network = "test-network"
#          }
#        }
#      }
#    ]
#
#    graphics = [
#      {
#        vnc = {
#          autoport = "yes"
#          listen   = "127.0.0.1"
#        }
#      }
#    ]
#  
#  }
#
#  running = true
#}
#
