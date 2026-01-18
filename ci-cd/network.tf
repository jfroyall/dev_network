# The control sub-networks
resource "libvirt_network" "control" {
  for_each = var.all_control_networks
  name      = each.value.name
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
    address = each.value.ip
    prefix  = each.value.prefix
    #netmask = "255.255.255.0"

    ranges = [
      {
        start = each.value.start
        end   = each.value.end
      },
    ]

    dhcp = {
      #      hosts = {
      #        ip
      #      }
      ranges = [
        {
          start = each.value.start
          end   = each.value.end
        },
      ]

    }
    }
  ]

  domain = {
    local_only = "yes"
    name       = each.value.domain_name
    register   = "yes"
  }

  forward = {
    #addresses = [{ }]

    #dev = ""

    #driver = { }

    #interfaces = [{ }]

    #managed = false

    #mode = "route"
    mode = "nat"

    nat = {
      port = {
        start = 1024
        end   = 65535
      }
    }

  }
}
#resource "libvirt_network" "outer" {
#  name      = "outer-network"
#  autostart = "false"
#
#  dns = {
#    enable = "yes"
#    host   = [ { 
#                  ip = "192.168.1.96"
#                  hostnames = [
#                    {
#                      hostname = "papa"
#                    }
#                  ]
#               }
#             ]
#       #forward_plain_names   =
#  }
#
#  ips = [{
#    address = "192.168.96.0"
#    prefix  = 24
#    #netmask = "255.255.255.0"
#
#    ranges = [
#      {
#        start = "192.168.96.128"
#        end   = "192.168.96.191"
#      },
#    ]
#
#    dhcp = {
#      #      hosts = {
#      #        ip
#      #      }
#      ranges = [
#        {
#          start = "192.168.96.128"
#          end   = "192.168.96.191"
#        },
#      ]
#
#    }
#    }
#  ]
#
#  domain = {
#    local_only = "yes"
#    name       = "control.dabilly.home"
#    register   = "yes"
#  }
#
#  forward = {
#    #addresses = [{ }]
#
#    #dev = ""
#
#    #driver = { }
#
#    #interfaces = [{ }]
#
#    #managed = false
#
#    #mode = "route"
#    mode = "nat"
#
#    nat = {
#      port = {
#        start = 1024
#        end   = 65535
#      }
#    }
#
#  }
#}

# The inner sub-network
resource "libvirt_network" "inner" {
  for_each = var.all_inner_networks
  name      = each.value.name
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
    address = each.value.ip
    prefix  = each.value.prefix
    #netmask = "255.255.255.0"

    ranges = [
      {
        start = each.value.start
        end   = each.value.end
      },
    ]

    dhcp = {
      #      hosts = {
      #        ip
      #      }
      ranges = [
        {
          start = each.value.start
          end   = each.value.end
        },
      ]

    }
    }
  ]

  domain = {
    local_only = "yes"
    name       = each.value.domain_name
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
