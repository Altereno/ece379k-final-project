variable "endpoint" {
  description = "Endpoint for Proxmox host"
  type        = string
}

variable "api_token" {
  description = "API token for proxmox user"
  type        = string
  sensitive   = true
}

variable "username" {
  description = "PVE User"
  type        = string
}

variable "password" {
  description = "PVE User password"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "image_datastore_id" {
  description = "Image download datastore location"
  type        = string
}

variable "vm_datastore_id" {
  description = "VM image datastore location"
  type        = string
}

variable "vm_names" {
  description = "List of vm names"
  type        = list(string)
}

variable "network_bridge_device" {
  description = "Network bridge device for nodes"
  type        = string
}

variable "ipv4_gateway" {
  description = "Default gateway for nodes"
  type        = string
}

variable "dns_servers" {
  description = "DNS server for nodes"
  type        = list(string)
}

variable "vm_cores" {
  description = "Number of cores for each vm"
  type        = number
  default     = 2
}

variable "vm_ram_size" {
  description = "Size in MB for vm RAM"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "VM disk size"
  type        = number
  default     = 10
}

variable "vm_ipv4_prefix" {
  description = "IPv4 prefix for vm"
  type        = string
}

variable "ubuntu_base_image_url" {
  description = "Ubuntu image url"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for Ansible access"
  type        = string
}