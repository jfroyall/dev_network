
#
# Cloud-init seed ISO.
resource "libvirt_cloudinit_disk" "alpine_seed" {

  for_each = local.all_cloud_init_isos
#  for_each = tomap({
#    for sn_key, sn in local.vms_and_subnets : "${sn.host_name}.${sn.branch}.${sn.network}" => sn
#  })

  name = "alpine-cloudinit"

  #user_data = file("user-data.yaml")
  user_data = templatefile(each.value.user_data,  { 
                            host_name = "${each.value.host_name}", 
                            network   = "${each.value.network}",
                            branch    = "${each.value.branch}"
                            }
                            )

  meta_data = <<-EOF
    instance-id: ${each.value.host_name}
    local-hostname: ${each.value.host_name}
  EOF

  network_config = <<-EOF
    version: 2
    ethernets:
      eth0:
        dhcp4: true
  EOF
}


#
# Upload the cloud-init ISO into the pool.
resource "libvirt_volume" "alpine_seed_volume" {

  for_each = local.all_seed_volumes
  #for_each = tomap({
  #  for sn_key, sn in local.vms_and_subnets : "${sn.host_name}.${sn.branch}.${sn.network}" => sn
  #})


  name = "alpine-cloudinit-${each.key}.iso"
  pool = libvirt_pool.basic["os-isos"].name

  create = {
    content = {
      url = libvirt_cloudinit_disk.alpine_seed["${each.key}"].path
    }
  }
}
