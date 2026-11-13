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

# Télécharge automatiquement l'image Cloud Debian 13 (Trixie) sur l'hôte XCP-ng
# et crée le Template "Debian 13 Cloud-Init" s'il n'existe pas encore.
resource "terraform_data" "debian13_template" {
  triggers_replace = [
    var.xo_template_name,
    var.debian_cloud_image_url,
    data.xenorchestra_sr.sr.id
  ]

  connection {
    type     = "ssh"
    host     = var.xcp_host
    user     = var.xcp_user
    password = var.xcp_password
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
      set -e
      EXISTING=$(xe template-list name-label="${var.xo_template_name}" --minimal)
      if [ -n "$EXISTING" ]; then
        echo "Template '${var.xo_template_name}' deja present ($EXISTING)."
        exit 0
      fi

      echo "Telechargement de l'image Debian 13 Cloud..."
      curl -fSL "${var.debian_cloud_image_url}" -o /tmp/debian-13-cloud.raw
      IMG_SIZE=$(stat -c%s /tmp/debian-13-cloud.raw)

      echo "Creation du VDI dans le SR (${data.xenorchestra_sr.sr.id})..."
      VDI_UUID=$(xe vdi-create sr-uuid="${data.xenorchestra_sr.sr.id}" name-label="debian-13-cloud-base" type=system virtual-size="$IMG_SIZE")
      xe vdi-import uuid="$VDI_UUID" filename=/tmp/debian-13-cloud.raw format=raw
      rm -f /tmp/debian-13-cloud.raw

      echo "Creation du Template VM '${var.xo_template_name}'..."
      VM_UUID=$(xe vm-install template="Other install media" new-name-label="${var.xo_template_name}")
      xe vbd-create vm-uuid="$VM_UUID" vdi-uuid="$VDI_UUID" device=0 bootable=true mode=RW type=Disk >/dev/null
      xe vm-param-set uuid="$VM_UUID" is-a-template=true other-config:instant=true name-description="Debian 13 Cloud-Init (importe par Terraform)"

      sleep 5
      EOT
    ]
  }
}

data "xenorchestra_template" "debian" {
  name_label = var.xo_template_name
  pool_id    = data.xenorchestra_pool.pool.id
  depends_on = [terraform_data.debian13_template]
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
