output "all_vms" {
 description = "Description of the VMS"
 value       = var.all_vms
}
output "vm_condition_poweron" {
 description = "Public IP of the web instance"
 value       = var.vm_condition_poweron
}
output "vm_IP_addresses" {
 description = "IP_addresses of the instances"
 value       = var.vm_condition_poweron
}
output "instance_count" {
 description = "Number of instances"
 value       = var.instance_count
}
output "instance_ips" {
  #value = libvirt_domain.alpine.devices.interface[*].ip.address
  #value = libvirt_domain.alpine.devices.interfaces[*].source.ip
  #value = libvirt_domain.alpine.devices.interfaces[*].ip
  #value = libvirt_domain.alpine
  value = "foobar"
}

#output "lb_address" {
#  value = aws_alb.web.public_dns
#}
