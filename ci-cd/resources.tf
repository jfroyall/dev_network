# Basic pool
resource "libvirt_pool" "default" {
  name = "scratch-pool"
  type = "dir"
  source = {
#    host = "localhost" 
    dir = "/scratch/scratch-pool" 
  }
  target = {
    path = "/scratch/scratch-pool"
  }
}

# Volume from HTTP URL upload
resource "libvirt_volume" "alpine_base" {
  name   = "alpine-3.22.2.qcow2"
  pool   = libvirt_pool.default.name
  format = "qcow2"

  create = {
    content = {
      url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.2-x86_64-bios-cloudinit-r0.qcow2"
    }
  }
  # capacity is automatically computed from Content-Length header
}

# Writable copy-on-write layer for the VM.
resource "libvirt_volume" "alpine_disk" {
  name     = "alpine-vm.qcow2"
  pool     = libvirt_pool.default.name
  format   = "qcow2"
  capacity = 2147483648

  backing_store = {
    path   = libvirt_volume.alpine_base.path
    format = "qcow2"
  }
}



# Cloud-init seed ISO.
resource "libvirt_cloudinit_disk" "alpine_seed" {
  name = "alpine-cloudinit"

  user_data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        root:password
      expire: false

    ssh_pwauth: true

    packages:
      - openssh-server

    timezone: UTC
  EOF

  meta_data = <<-EOF
    instance-id: alpine-001
    local-hostname: alpine-vm
  EOF

  network_config = <<-EOF
    version: 2
    ethernets:
      eth0:
        dhcp4: true
  EOF
}

# Upload the cloud-init ISO into the pool.
resource "libvirt_volume" "alpine_seed_volume" {
  name = "alpine-cloudinit.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.alpine_seed.path
    }
  }
}

# A sub-network
resource "libvirt_network" "test" {
  name = "test-network"
  autostart = "false"
  ips = [ {
    address = "192.168.96.0"
    netmask = "255.255.255.0"
#    prefix = 24
#    dhcp= {
#      hosts = {
#        ip
#      }
#      ranges = []
#    }
  }
  ]
#
#  dns = {
#    enable = "true"
#    #host   =
#    #forward_plain_names   =
#  }
#  domain = {
#    local_only = "false"
#    name       = "nowhere.net"
#
#  }
#  #forward = 
}


# Basic volume
#resource "libvirt_volume" "example" {
#  name = "example.qcow2"
#  #pool     = "${libvirt_pool.default}.name"
#  pool     = "default"
#  capacity = 1073741824 # 1 GB
#  format   = "qcow2"
#}
#
#resource "libvirt_volume" "vm-qcow2" {
#  name   = "guest.qcow2"
#  pool   = libvirt_pool.vmpool.name
#  source = "${path.module}/sources/guest.qcow2"
#  format = "qcow2"
#}
## Volume with backing store
#resource "libvirt_volume" "base" {
#  name     = "base.qcow2"
#  pool     = "default"
#  capacity = 10737418240
#  format   = "qcow2"
#}
#
#resource "libvirt_volume" "overlay" {
#  name     = "overlay.qcow2"
#  pool     = "default"
#  capacity = 10737418240
#
#  backing_store = {
#    path   = libvirt_volume.base.path
#    format = "qcow2"
#  }
#}
#
## Volume from HTTP URL upload
#resource "libvirt_volume" "ubuntu_base" {
#  name   = "ubuntu-22.04.qcow2"
#  pool   = "default"
#  format = "qcow2"
#
#  create = {
#    content = {
#      url = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
#    }
#  }
#  # capacity is automatically computed from Content-Length header
#}
#
## Volume from local file upload
#resource "libvirt_volume" "from_local" {
#  name   = "custom-image.qcow2"
#  pool   = "default"
#  format = "qcow2"
#
#  create = {
#    content = {
#      url = "/path/to/local/image.qcow2"
#      # or: url = "file:///path/to/local/image.qcow2"
#    }
#  }
#  # capacity is automatically computed from file size
#}


