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

