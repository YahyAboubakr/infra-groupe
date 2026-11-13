output "id" {
  value = xenorchestra_vm.vm.id
}

output "ip" {
  value = split("/", var.ip_cidr)[0]
}
