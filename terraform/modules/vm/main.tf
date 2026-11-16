terraform {
  required_providers {
    xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = ">= 0.35.0, < 1.0.0"
    }
  }
}

locals {
  cloud_config = templatefile("${path.module}/cloud_init.cfg.tftpl", {
    hostname = var.name
    domain   = var.domain
    username = var.username
    password = var.password
    ssh_key  = var.ssh_pubkey
  })

  cloud_network_config = yamlencode({
    version = 2
    ethernets = {
      vif0 = {
        match       = { name = "e*" }
        dhcp4       = false
        addresses   = [var.ip_cidr]
        routes      = [{ to = "default", via = var.gateway }]
        nameservers = { addresses = var.dns_servers, search = [var.domain] }
      }
    }
  })
}

resource "xenorchestra_vm" "vm" {
  name_label       = var.name
  name_description = var.description
  template         = var.template_id
  cpus             = var.vcpu
  memory_max       = var.memory_mib * 1024 * 1024
  auto_poweron     = true
  power_state      = "Running"
  affinity_host    = var.affinity_host
  high_availability = var.high_availability
  
  cloud_config         = local.cloud_config
  cloud_network_config = local.cloud_network_config

  network {
    network_id = var.network_id
  }

  disk {
    sr_id      = var.sr_id
    name_label = "${var.name}-root"
    size       = var.disk_gib * 1024 * 1024 * 1024
  }

  lifecycle {
    precondition {
      condition     = var.ssh_pubkey != ""
      error_message = "Clé SSH publique non fournie. Veuillez fournir une clé SSH publique pour la configuration cloud-init."
    }
  }

  tags = ["soc", "terraform"]
}
