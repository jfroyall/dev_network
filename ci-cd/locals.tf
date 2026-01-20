
# The collection of objects required to construct the VMs/domains
locals {
  all_vm_descriptors =  tomap({
  for sn_key, sn in 
  flatten([
    for vm in var.all_vms:[
      for branch in var.all_branches:[
                          {
                          user_data = vm.user_data
                          host_name = vm.name
                          network   = vm.network
                          branch    = branch
                          sub_net   = "${vm.network}_${branch}"

                          #image     = vm.image
                          #sof_disk  = vm.sof_disk

                          }
      ]
    ]
    ]): "${sn.host_name}.${sn.branch}.${sn.network}" => sn
    })
}

# The collection of objects required to construct  cloud-init ISOs
locals {
  all_cloud_init_isos =  tomap({
  for sn_key, sn in 
  flatten([
    for vm in var.all_vms:[
      for branch in var.all_branches:[
                          {
                          user_data = vm.user_data
                          host_name = vm.name
                          network   = vm.network
                          branch    = branch
                          }
      ]
    ]
  ]): "${sn.host_name}.${sn.branch}.${sn.network}" => sn
  })
}

# The collection of objects required to construct  seed_volumes
locals {
  all_seed_volumes =  tomap({
  for sn_key, sn in 
  flatten([
    for vm in var.all_vms:[
      for branch in var.all_branches:[
                          {
                          host_name = vm.name
                          branch    = branch
                          network   = vm.network

                          #user_data = vm.user_data
                          #image     = vm.image
                          #sof_disk  = vm.sof_disk
                          }
      ]
    ]
    ]): "${sn.host_name}.${sn.branch}.${sn.network}" => sn
    })
}


# The collection of objects required to construct  copy-on-write disks
locals {
  all_cow_disks =  tomap({
  for sn_key, sn in 
  flatten([
    for vm in var.all_vms:[
      for branch in var.all_branches:[
            #"${vm.name}.${branch}.${vm.network}" = {
                          {
                          user_data = vm.user_data
                          host_name = vm.name
                          network   = vm.network
                          image     = vm.image
                          sof_disk  = vm.sof_disk
                          branch    = branch
                          }
      ]
    ]
    ]): "${sn.host_name}.${sn.branch}.${sn.network}" => sn
    })
}

# The collection of objects required to construct a VM
locals {
  network_descriptors = merge(var.all_control_networks, var.all_inner_networks) 
}

locals {
  vms_and_subnets = flatten([
    for vm_key, vm in var.all_vms:[
      for branch in var.all_branches:{
        user_data = vm.user_data
        host_name = vm.name
        network   = vm.network
        image     = vm.image
        sof_disk  = vm.sof_disk
        branch    = branch
      }
    ]
  ])
}

# The collection of objects required to construct a VM
locals {
  vms_desc = flatten([
    for vm_key, vm in var.all_vms:[
      for branch in var.all_branches:{
        user_data = vm.user_data
        host_name = vm.name
        network   = vm.network
        image     = vm.image
        sof_disk  = vm.sof_disk
        branch    = branch
      }
    ]
  ])
}
