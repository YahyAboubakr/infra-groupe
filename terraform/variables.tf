variable "xo_url" {
  description = "URL WebSocket de Xen Orchestra (ex: wss://192.168.1.10)"
  type        = string
}

variable "xo_username" {
  description = "Utilisateur Xen Orchestra"
  type        = string
}

variable "xo_password" {
  description = "Mot de passe Xen Orchestra"
  type        = string
  sensitive   = true
}

variable "xo_insecure" {
  description = "Ignorer la vérification TLS (certificat auto-signé)"
  type        = bool
  default     = true
}

variable "xcp_host" {
  description = "Adresse IP ou hostname du serveur XCP-ng master (pour télécharger l'image Cloud Debian 13)"
  type        = string
}

variable "xcp_user" {
  description = "Utilisateur SSH de l'hôte XCP-ng"
  type        = string
  default     = "root"
}

variable "xcp_password" {
  description = "Mot de passe SSH de l'hôte XCP-ng"
  type        = string
  sensitive   = true
}

variable "debian_cloud_image_url" {
  description = "URL officielle de l'image Cloud Debian 13 (Trixie) au format RAW pour XCP-ng"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.raw"
}

variable "xo_pool_name" {
  description = "Nom du Pool XCP-ng dans Xen Orchestra"
  type        = string
}

variable "xo_template_name" {
  description = "Nom du Template Debian 13 Cloud-Init créé dans XCP-ng"
  type        = string
  default     = "Debian 13 Cloud-Init"
}

variable "xo_sr_name" {
  description = "Nom du Storage Repository (SR)"
  type        = string
  default     = "Local storage"
}

variable "xo_network_name" {
  description = "Nom du réseau / VLAN dans Xen Orchestra"
  type        = string
}

variable "ips" {
  description = "Adresses IPv4 fixes des VM SOC (VLAN 30)"
  type        = object({ wazuh1 = string, gvm1 = string })
  default = {
    wazuh1 = "192.168.30.20"
    gvm1   = "192.168.30.30"
  }
}

variable "prefix_len" {
  type    = number
  default = 24
}

variable "gateway" {
  type    = string
  default = "192.168.30.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["192.168.30.1"]
}

variable "domain" {
  type    = string
  default = "ad.groupe.lan"
}

variable "vm_username" {
  type    = string
  default = "admin"
}

variable "vm_password" {
  type      = string
  sensitive = true
}

variable "ssh_pubkey_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
