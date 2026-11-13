
data "xenorchestra_pool" "pool" {
  name_label = "xen5-master"
}

data "xenorchestra_template" "tpl" {
  name_label = "Other install media"
  pool_id    = data.xenorchestra_pool.pool.id
}

data "xenorchestra_network" "net" {
  name_label = "Pool-wide network 0"
  pool_id    = data.xenorchestra_pool.pool.id
}

data "xenorchestra_sr" "sr" {
  name_label = "XEN1-NFS"        # à remplacer, voir ci-dessous
  pool_id    = data.xenorchestra_pool.pool.id
}

data "xenorchestra_vdi" "iso" {
  name_label = "debian-13.7.0-amd64-netinst.iso"
  pool_id    = data.xenorchestra_pool.pool.id
}

resource "xenorchestra_vm" "debian" {
  name_label = "debian-test"
  template   = data.xenorchestra_template.tpl.id
  cpus       = 2
  memory_max = 2147483648            # 2 Go

  cdrom {
    id = data.xenorchestra_vdi.iso.id
  }

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.sr.id
    name_label = "debian-test-disk"
    size       = 10737418240         # 20 Go
  }
}
