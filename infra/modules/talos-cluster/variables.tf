variable "cluster_name" {
  type = string
  default = "talos-cluster-01"
  description = "The name of the Talos cluster"
  validation {
    condition = can(regex("^[A-Za-z0-9][A-Za-z0-9._-]*$", var.cluster_name))
    error_message = "The cluster name must start with a letter/number and contain only A–Z, a–z, 0–9, '-', '.', '_'."
  }
}

variable "control_plane_nodes" {
  description = "List of IPv4 addresses for control plane nodes"
  type        = list(string)

  # Validates each value is an IPv4 address
  validation {
    condition = alltrue([
      for ip in var.control_plane_nodes : can(cidrnetmask("${ip}/32"))
    ])
    error_message = "Each value must be a valid IPv4 address (e.g., 10.0.0.1)."
  }
}