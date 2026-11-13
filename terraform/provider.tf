terraform {
  required_providers {
    xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = "~> 0.41"
    }
  }
}

# Auth par utilisateur / mot de passe (variables, valeurs dans terraform.tfvars
# ou TF_VAR_xo_password). Ne pas définir XOA_TOKEN en même temps.
provider "xenorchestra" {
  url      = var.xo_url
  username = var.xo_username
  password = var.xo_password
  insecure = var.xo_insecure
}
