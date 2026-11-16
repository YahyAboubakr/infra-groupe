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
  type        = object({ wazuh = string, gvm1 = string })
  default = {
    wazuh = "192.168.30.20"
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
