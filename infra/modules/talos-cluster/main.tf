
resource "talos_machine_secrets" "cluster_secret" {}

data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${module.talos01.ip}:6443"
  machine_secrets  = talos_machine_secrets.cluster_secret.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster_secret.client_configuration
  nodes                = var.control_plane_nodes
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.cluster_secret.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = module.talos01.ip
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = module.talos01.ip
  client_configuration = talos_machine_secrets.cluster_secret.client_configuration
}


resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.cluster_secret.client_configuration
  node                 = module.talos01.ip
}