data "xenorchestra_pool" "pool" {
  name_label = var.xo_pool_name
}

data "xenorchestra_sr" "sr" {
  name_label = var.xo_sr_name
  pool_id    = data.xenorchestra_pool.pool.id
}

data "xenorchestra_network" "net" {
  name_label = var.xo_network_name
  pool_id    = data.xenorchestra_pool.pool.id
}

# Template Debian 13 cloud-init fourni par l'équipe Xen (déjà présent dans XO).
data "xenorchestra_template" "debian" {
  name_label = var.xo_template_name
  pool_id    = data.xenorchestra_pool.pool.id
}

locals {
  vms = {
    wazuh1 = {
      description = "Wazuh All-in-One (Indexer + Manager + Dashboard)"
      vcpu        = 4
      memory_mib  = 8192
      disk_gib    = 50
      ip          = var.ips.wazuh1
    }
    gvm1 = {
      description = "Greenbone / OpenVAS Vulnerability Scanner"
      vcpu        = 4
      memory_mib  = 8192
      disk_gib    = 60
      ip          = var.ips.gvm1
    }
  }
}

module "vm" {
  source   = "./modules/vm"
  for_each = local.vms

  name        = each.key
  description = each.value.description
  vcpu        = each.value.vcpu
  memory_mib  = each.value.memory_mib
  disk_gib    = each.value.disk_gib

  template_id   = data.xenorchestra_template.debian.id
  sr_id         = data.xenorchestra_sr.sr.id
  network_id    = data.xenorchestra_network.net.id
  affinity_host = data.xenorchestra_pool.pool.master

  ip_cidr     = "${each.value.ip}/${var.prefix_len}"
  gateway     = var.gateway
  dns_servers = var.dns_servers
  domain      = var.domain

  username   = var.vm_username
  password   = var.vm_password
  ssh_pubkey = fileexists(pathexpand(var.ssh_pubkey_path)) ? trimspace(file(pathexpand(var.ssh_pubkey_path))) : ""
}
