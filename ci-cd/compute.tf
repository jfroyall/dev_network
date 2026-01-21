##
## Virtual machine definition.

resource "libvirt_domain" "alpine" {

  for_each = local.all_vm_descriptors


  name   = each.key
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
    boot_devices = [{dev = "hd"}, {dev = "cdrom"}]

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
            pool   = "vm-images"
            volume = libvirt_volume.vm_disk["${each.key}"].name
            #volume = "${each.value.name}.qcow2"
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

      /*
      {
        device = "cdrom"
        source = {
          volume = {
            pool   = libvirt_volume.ISOs["${each.value.image}"].pool
            volume = libvirt_volume.ISOs["${each.value.image}"].name
          }
        }
        target = {
          dev = "sdb"
          bus = "sata"
        }
      }
      */

      {
        device = "cdrom"
        source = {
          volume = {
            pool   = libvirt_volume.alpine_seed_volume["${each.key}"].pool
            volume = libvirt_volume.alpine_seed_volume["${each.key}"].name
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
            network = "${each.value.sub_net}"
          }
        }
      }
    ]

    serials = [
      {
      }
    ]
    consoles = [
      {
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

