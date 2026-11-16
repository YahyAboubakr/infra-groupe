output "vms" {
  description = "Nom -> IP des VM créées"
  value       = { for k, m in module.vm : k => m.ip }
}

output "wazuh_workers" {
  description = "Nom -> IP des Wazuh Workers (autoscaling)"
  value       = { for k, m in module.vm : k => m.ip if startswith(k, "wazuh-worker-") }
}
