
## Pools 
resource "libvirt_pool" "basic" {

  for_each = var.all_pools

    name = "${each.value}"
    type = "dir"
    target = {
      path = "/scratch/${each.value}-pool"
    }
}
