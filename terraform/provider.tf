terraform {
  required_providers {
    xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = "~> 0.41"
    }
  }
}

# Auth par token du compte svc_terraform, lu dans l'environnement :
#   export XOA_TOKEN='...'
# Ne jamais mettre le token (ni username/password) dans ce fichier.
provider "xenorchestra" {
  url      = var.xo_url
  insecure = var.xo_insecure
}
