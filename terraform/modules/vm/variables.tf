variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "VM SOC"
}

variable "vcpu" {
  type = number
}

variable "memory_mib" {
  type = number
}

variable "disk_gib" {
  type = number
}

variable "template_id" {
  type = string
}

variable "sr_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "affinity_host" {
  type    = string
  default = null
}

variable "ip_cidr" {
  type = string
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "domain" {
  type    = string
  default = "ad.groupe.lan"
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "ssh_pubkey" {
  type    = string
  default = ""
}
