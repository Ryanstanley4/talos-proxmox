variable "cluster_name" {
  type        = string
  description = "Logical name for the cluster."
}

variable "control_plane_nodes" {
  description = "IPv4 addresses of your control-plane nodes."
  type        = list(string)

  validation {
    condition = alltrue([
      for ip in var.control_plane_nodes :
      can(cidrnetmask("${ip}/32"))
    ])
    error_message = "Each control-plane node must be a valid IPv4 address."
  }
}

variable "install_disk" {
  type        = string
  default     = "/dev/vda"
  description = "Disk to install Talos onto."
}

variable "cluster_endpoint" {
  type        = string
  default     = null
  description = "Optional Kubernetes API endpoint (e.g. https://lb.example.com:6443). If null, uses https://<bootstrap_node>:6443."
}

variable "bootstrap_node" {
  type        = string
  default     = null
  description = "IP of the control-plane node to bootstrap first. If null, the first entry in control_plane_nodes is used."

  # 1) Must be a valid IPv4 when provided
  validation {
    condition     = var.bootstrap_node == null || can(cidrnetmask("${var.bootstrap_node}/32"))
    error_message = "bootstrap_node must be a valid IPv4 address (or null)."
  }

  # 2) Must be one of the control_plane_nodes when provided
  validation {
    condition     = var.bootstrap_node == null || contains(var.control_plane_nodes, var.bootstrap_node)
    error_message = "bootstrap_node must be one of control_plane_nodes (or null)."
  }
}

variable "control_plane_count" {
  description = "Number of control-plane nodes (must match length of control_plane_nodes). Used to avoid dynamic for_each keys at plan time."
  type        = number
}
