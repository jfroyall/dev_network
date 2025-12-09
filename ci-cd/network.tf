
# A sub-network
resource "libvirt_network" "test" {
  name      = "test-network"
  autostart = "false"

#  dns = {
#    enable = "true"
#   #host   =
#   #forward_plain_names   =
#  }

  ips = [ {
    address = "192.168.96.0"
    prefix = 24
    #netmask = "255.255.255.0"
#    dhcp= {
#      hosts = {
#        ip
#      }
#      ranges = []
#    }
  }
  ]

#  domain = {
#    local_only = "false"
#    name       = "nowhere.net"
#
#  }
#  #forward = {}
}
