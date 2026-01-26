locals {
  uri_map = {
    "papa" = "qemu://system"
    "mac"  = "qemu+sshcmd://jean@192.168.1.96/system?keyfile=/home/jean/.ssh/id_rsa&no_verify=0&sshauth=privkey"
  }

  scratch_map = {
    "papa" = "/scratch"
    "mac"  = "/Users/jean/Scratch"
  }

}


locals {
  t_control_networks ={
        for b in var.all_branches : 
            "control_${b}" => {
                                name   = "control_${b}"
                                cidr   = format("172.%s.17.0",
                                                  "${var.ip_octet[b]}")
                                prefix = "24"
                                start  = format("172.%s.17.129",
                                                  "${var.ip_octet[b]}")
                                end    = format("172.%s.17.192",
                                                  "${var.ip_octet[b]}")
                                domain_name  = "control.${b}.office.home"
                                }
  }

  t_internal_networks ={
        for b in var.all_branches : 
            "internal_${b}" => {
                                name   = "internal_${b}"
                                cidr   = format("172.%s.18.0",
                                                  "${var.ip_octet[b]}")
                                prefix = "24"
                                start  = format("172.%s.18.129",
                                                  "${var.ip_octet[b]}")
                                end    = format("172.%s.18.192",
                                                  "${var.ip_octet[b]}")
                                domain_name  = "internal.${b}.office.home"
                                }
  }

}
# The collection of objects required to construct the networks
locals {
  #network_descriptors = merge(var.all_control_networks, var.all_inner_networks) 
  network_descriptors = merge(local.t_control_networks, local.t_internal_networks) 
}




