# The control sub-networks
resource "libvirt_network" "sub_networks" {

  for_each = local.network_descriptors

  name      = each.value.name
  autostart = "false"

  dns = {
    enable = "yes"
    host   = [ { 
                  ip = var.platform_ip
                  hostnames = [
                    {
                      hostname = var.platform_dns_name
                    }
                  ]
               }
             ]
       #forward_plain_names   =
  }

  ips = [{
    address = each.value.cidr
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

