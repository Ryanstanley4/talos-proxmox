locals {
  # Ordered list for deterministic indexing
  cp_nodes         = var.control_plane_nodes
  bootstrap_node   = coalesce(var.bootstrap_node, var.control_plane_nodes[0])
  rest_nodes       = [for n in var.control_plane_nodes : n if n != local.bootstrap_node]
  cluster_endpoint = var.cluster_endpoint != null ? var.cluster_endpoint : "https://${local.bootstrap_node}:6443"
}

resource "talos_machine_secrets" "cluster_secret" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.cluster_secret.machine_secrets
}

# Apply to bootstrap node
resource "talos_machine_configuration_apply" "bootstrap" {
  client_configuration        = talos_machine_secrets.cluster_secret.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.bootstrap_node
  config_patches = [
    yamlencode({ machine = { install = { disk = var.install_disk } } })
  ]
}

# Apply to the remaining nodes (after bootstrap node)
resource "talos_machine_configuration_apply" "others" {
  # Use a static count to avoid unknown for_each keys at plan time
  count = var.control_plane_count - 1

  client_configuration        = talos_machine_secrets.cluster_secret.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.rest_nodes[count.index]
  config_patches = [
    yamlencode({ machine = { install = { disk = var.install_disk } } })
  ]

  depends_on = [talos_machine_configuration_apply.bootstrap]
}

# Now bootstrap the cluster
resource "talos_machine_bootstrap" "this" {
  node                 = local.bootstrap_node
  client_configuration = talos_machine_secrets.cluster_secret.client_configuration
  depends_on           = [talos_machine_configuration_apply.bootstrap]
}

# Retrieve kubeconfig once the cluster is bootstrapped
resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.cluster_secret.client_configuration
  node                 = local.bootstrap_node
}
