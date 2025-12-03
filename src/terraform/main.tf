terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_base_image" {
  node_name               = var.node_name
  content_type            = "iso"
  datastore_id            = var.image_datastore_id
  file_name               = "compsec-ubuntu_base_image"
  url                     = var.ubuntu_base_image_url
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "vms" {
  count       = length(var.vm_names)
  name        = var.storage_account_names[count.index]
  description = "Managed by Terraform"
  tags        = ["compsec"]
  node_name   = var.node_name

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.vm_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.vm_ram_size
  }

  disk {
    datastore_id = var.vm_datastore_id
    discard      = "on"
    iothread     = true
    file_format  = "raw"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_base_image.id
    interface    = "virtio0"
    size         = var.vm_disk_size
  }

  network_device {
    bridge = var.network_bridge_device
  }

  initialization {
    datastore_id = var.vm_datastore_id
    user_account {
      username = "compsec"
      keys = [
        file(var.ssh_key_file)
      ]
    }
    dns {
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        gateway = var.ipv4_gateway
        address = "${cidrhost(var.vm_ipv4_prefix, count.index)}/24"
      }
    }

  }
}
