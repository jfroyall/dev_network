
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
