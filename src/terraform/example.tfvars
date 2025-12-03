endpoint  = "https://proxmox:8006/"
api_token = "user@pam!token=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
username  = "user"
password  = "abcd123"

node_name          = "pve"
image_datastore_id = "local-zfs"
vm_datastore_id    = "local-zfs"

network_bridge_device = "vmbr0"
ipv4_gateway          = "192.168.0.1"
dns_servers           = ["1.1.1.1"]

vm_cores       = 4
vm_ram_size    = 6144
vm_disk_size   = 20
vm_ipv4_prefix = "192.168.0.64/26"

vm_names = ["compsecproj-native", "compsecproj-kyverno", "compsecproj-gatekeeper"]

ssh_public_key = "../keys/ansible.pub"
