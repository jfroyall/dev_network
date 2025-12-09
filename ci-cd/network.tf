
# A sub-network
resource "libvirt_network" "test" {
  name      = "test-network"
  autostart = "false"

  dns = {
    enable = "yes"
    host   = [ { 
                  ip = "192.168.1.96"
                  hostnames = [
                    {
                      hostname = "papa"
                    }
                  ]
               }
             ]
       #forward_plain_names   =
  }

  ips = [{
    address = "192.168.96.0"
    prefix  = 24
    #netmask = "255.255.255.0"

    ranges = [
      {
        start = "192.168.96.128"
        end   = "192.168.96.192"
      },
    ]

    dhcp = {
      #      hosts = {
      #        ip
      #      }
      ranges = [
        {
          start = "192.168.96.128"
          end   = "192.168.96.191"
        },
      ]

    }
    }
  ]

  domain = {
    local_only = "yes"
    name       = "no.where.home"
  }

  #forward = {}
}
