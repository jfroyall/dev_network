
## Pools 
resource "libvirt_pool" "basic" {

  for_each = var.all_pools

    name = "${each.value}"
    type = "dir"
    target = {
      path = "${var.scratch_dir}/${each.value}-pool"
    }
}
