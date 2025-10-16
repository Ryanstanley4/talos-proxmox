# modules/proxmox-vm/main.tf
resource "proxmox_vm_qemu" "vm" {
  for_each = { for i in range(var.vm_count) : i => i }

  name        = "${var.name_prefix}${each.key + 1}"
  target_node = var.target_nodes[each.key % length(var.target_nodes)]

  cpu {
    sockets = var.sockets
    cores   = var.cores
  }
  memory     = var.memory_mb
  agent      = 1
  onboot     = true
  skip_ipv6  = true

  boot = "order=scsi0;ide2"

  disks {
    virtio {
      virtio0 {
        disk {
          storage = var.storage
          size    = "${var.disk_gb}G"
        }
      }
    }
    ide {
      ide2 {
        cdrom {
          iso = "${var.iso_storage}:iso/${var.iso_file}"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
    tag    = var.vlan_tag
  }

  tags = length(local.tags_clean) > 0 ? join(";", local.tags_clean) : null
}


# modules/proxmox-vm/outputs.tf
output "vmids" {
  value = { for k, v in proxmox_vm_qemu.vm : k => v.vmid }
}

output "names" {
  value = { for k, v in proxmox_vm_qemu.vm : k => v.name }
}

output "ipv4_addresses" {
  description = "Default IPv4 addresses reported by qemu-guest-agent for each VM"
  value       = { for k, v in proxmox_vm_qemu.vm : k => v.default_ipv4_address }
}
