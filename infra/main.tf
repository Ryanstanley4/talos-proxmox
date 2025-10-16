module "talos_control" {
  source       = "./modules/proxmox-vm"
  name_prefix  = "talos-"
  vm_count     = 3
  target_nodes = ["suzuka", "spa"]
  storage      = "talos"
}


locals {
  control_plane_nodes = [
    for k in sort(keys(module.talos_control.ipv4_addresses)) :
    module.talos_control.ipv4_addresses[k]
  ]
}

module "talos_bootstrap" {
  source = "./modules/talos-cluster"

  cluster_name        = "home-k8s"
  control_plane_nodes = local.control_plane_nodes
  control_plane_count = 3
  bootstrap_node      = local.control_plane_nodes[0] # first node in the list
  install_disk        = "/dev/vda"

  depends_on = [module.talos_control] # wait until VMs exist
}
