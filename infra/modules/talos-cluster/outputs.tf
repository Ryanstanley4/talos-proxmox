output "bootstrap_node" {
  value = local.bootstrap_node
}

output "cluster_endpoint" {
  value = local.cluster_endpoint
}

output "kubeconfig_raw" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
