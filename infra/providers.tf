terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 3.0"  # pick a stable major you’re comfortable with
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}