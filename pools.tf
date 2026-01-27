
## Pools 
resource "libvirt_pool" "basic" {

  for_each = var.all_pools

    name = "${each.value}"
    type = "dir"
    target = {
      #path = "${var.scratch_dir}/${each.value}-pool"
      #path = "${local.scratch_map[var.dev_host]}/jenkins-agent-pool"
      path = "${var.pool_storage}/${each.value}-pool"
    }
}
