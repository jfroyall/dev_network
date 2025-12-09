#
# Virtual machine definition.
resource "libvirt_domain" "alpine" {
  name   = "alpine-vm"
  memory = 1048576
  vcpu   = 1

  os = {
    type    = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }

  devices = {
    disks = [
      {
        source = {
          pool   = libvirt_volume.alpine_disk.pool
          volume = libvirt_volume.alpine_disk.name
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device = "cdrom"
        source = {
          pool   = libvirt_volume.alpine_seed_volume.pool
          volume = libvirt_volume.alpine_seed_volume.name
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = "virtio"
        source = {
          network = "test-network"
        }
      }
    ]

    graphics = {
      vnc = {
        autoport = "yes"
        listen   = "127.0.0.1"
      }
    }
  }

  running = true
}



#resource "libvirt_domain" "jumpbox" {
#  name        = "jumpbox-vm"
#  type        = "kvm"
#  memory      = 512        # Flattened from <memory unit='MiB'>512</memory>
#  #memory_unit = "MiB"      # Optional, defaults based on libvirt
#  vcpu        = 1          # Flattened from <vcpu>1</vcpu>
#
#  clock ={
#    offset = "utc"
#
#    timer =[{
#      name       = "rtc"
#      tickpolicy = "catchup"
#
#      catchup ={
#        threshold = 123
#        slew      = 120
#        limit     = 10000
#      }
#    },
#
#    {
#      name       = "pit"
#      tickpolicy = "delay"
#    }
#    ]
#  }
#}
#
