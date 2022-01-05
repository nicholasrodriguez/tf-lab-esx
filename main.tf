provider "esxi" {
  esxi_hostname = "esx02"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = var.esxi_account
  esxi_password = var.LAB_PW
}

resource "esxi_guest" "vmtest" {
  guest_name = "vmtest"
  disk_store = "esx02_das01"
  network_interfaces {
    virtual_network = "lab_dev"
  }
}

output "esxi_message" {
  description = "End message"
  value       = var.esxi_account
}
