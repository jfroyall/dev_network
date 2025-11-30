terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt", version = "0.9.0"
    }
  }
}
terraform {
  required_version = ">= 1.13.5"
}

provider "libvirt" {
  # Configuration du fournisseur libvirt
  #uri = "qemu://jean@localhost/system"
  #uri = "qemu://jean@localhost/session"
  #uri = "qemu:///session"
  #uri = "qemu:///system"
  #uri = "qemu+ssh://jean@192.168.1.96/system"
  uri = "qemu+sshcmd://jean@192.168.1.96/system?keyfile=/home/jean/.ssh/id_rsa?no_verify=0?sshauth=privkey"
  #uri = "qemu+ssh://jean@192.168.1.96/system?knownhosts=/home/jean/.ssh/known_hosts?keyfile=/home/jean/.ssh/id_rsa?no_verify=1?sshauth=privkey"

}

#resource "libvirt_pool" "test" {
#  name        = "test-pool"
#  type        = "dir"
#  target      = {
#    path = "/Users/jean/Scratch/vm-pool"
#  }
#}

#resource "libvirt_domain" "example" {
#  name        = "example-vm"
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
