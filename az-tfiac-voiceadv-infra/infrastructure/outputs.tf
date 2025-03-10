output "name" {
  value = {
    appname = var.rgname
  }
}

output "linux_virtual_machine_ids" {
  description = "The resource id's of all Linux Virtual Machine."
  value       = module.linux-virtual-machine.*.linux_virtual_machine_ids
}


output "linux_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = module.linux-virtual-machine.*.linux_vm_public_ips
}