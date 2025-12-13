##
## Virtual machine definition.
resource "libvirt_domain" "alpine" {
  count = var.instance_count

  name   = "alpine-vm-${count.index}"
  type   = "kvm"
  memory = 2048
  memory_unit = "MiB"
  vcpu   = 1

#  cpu = {
#    check = "partial"
#    mode = "host-model"
#  }

  os = {
    type          = "hvm"
    #type_arch     = "x86_64"
    #type_machine  = "q35"
    boot_devices = [ {dev = "hd"}]

    #kernel      = "/boot/vmlinuz"
    #initrd      = "/boot/initrd.img"
    #kernel_args = "console=ttyS0 root=/dev/vda1"
    #boot_devices = [ {dev = "hd"}, {dev = "network"}]
    #boot_devices = [ {dev = "cdrom"}]
  }

  features = {
    acpi = true
    apic = {
      eoi = "off"
    }
    vm_port = {
      state = "off"
    }
  }

  on_poweroff = "destroy"
  on_reboot   = "restart"
  on_crash    = "destroy"

  destroy = {
    graceful = true
    timeout  = 30
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.alpine_disk[count.index].pool
            volume = libvirt_volume.alpine_disk[count.index].name
          }
        }
        target = {
          #dev = "vda"
          #bus = "virtio"
          dev = "sda"
          bus = "sata"
        }
        driver = { 
          type = "qcow2"
        }
        #boot = { order = 1 }
      },
      {
        device = "cdrom"
        source = {
          volume = {
            pool   = libvirt_volume.alpine_seed_volume[count.index].pool
            volume = libvirt_volume.alpine_seed_volume[count.index].name
          }
        }
        target = {
          dev = "sdb"
          bus = "sata"
        }
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "test-network"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          autoport = "yes"
          listen   = "127.0.0.1"
        }
      }
    ]
  
  }

  running = true
}

