resource "random_pet" "vm_name" {
  length    = 2
  separator = "-"
}

resource "esxi_guest" "vmtest" {
  #guest_name = random_pet.vm_name.id
  guest_name = "lvm10"
  disk_store = "esx02_das01"
  network_interfaces {
    virtual_network = "lab_dev"
  }
}

resource "fakewebservices_database" "test_server" {
  name = "Test Server 1"
  size = 512
}

output "esxi_message" {
  description = "End message"
  value       = var.esxi_account
}

output "test" {
  description = "End message"
  value       = var.vms[1]
}
