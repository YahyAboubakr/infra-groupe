output "vms" {
  description = "Nom -> IP des VM créées"
  value       = { for k, m in module.vm : k => m.ip }
}
