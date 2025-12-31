# The outer sub-network
resource "libvirt_network" "outer" {
  name      = "outer-network"
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
        end   = "192.168.96.191"
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
    name       = "management.dabilly.home"
    register   = "yes"
  }

  forward = {
    #addresses = [{ }]

    #dev = ""

    #driver = { }

    #interfaces = [{ }]

    #managed = false

    mode = "route"

#    nat = {
#      port = {
#        start = 1024
#        end   = 65535
#      }
#    }

  }
}

# The inner sub-network
resource "libvirt_network" "inner" {
  name      = "inner-network"
  autostart = "false"

  dns = {
    enable = "yes"
#    host   = [ { 
#                  ip = "192.168.96.1"
#                  hostnames = [
#                    {
#                      hostname = "papa"
#                    }
#                  ]
#               }
#             ]
       #forward_plain_names   =
  }

  ips = [{
    address = "192.168.97.0"
    prefix  = 24
    #netmask = "255.255.255.0"

    ranges = [
      {
        start = "192.168.97.128"
        end   = "192.168.97.191"
      },
    ]

    dhcp = {
      #      hosts = {
      #        ip
      #      }
      ranges = [
        {
          start = "192.168.97.128"
          end   = "192.168.97.191"
        },
      ]

    }
    }
  ]

  domain = {
    local_only = "yes"
    name       = "management.dabilly.home"
    register   = "yes"
  }

  forward = {
    #addresses = [{ }]

    #dev = ""

    #driver = { }

    #interfaces = [{ }]

    #managed = false

    mode = "nat"

    nat = {
      port = {
        start = 1024
        end   = 65535
      }
    }

  }
}
