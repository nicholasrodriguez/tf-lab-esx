terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
      #
      # For more information, see the provider source documentation:
      # https://github.com/josenk/terraform-provider-esxi
      # https://registry.terraform.io/providers/josenk/esxi
    }
  }
}

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
  #
  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  #clone_from_vm      = "Templates/centos7"
  #ovf_source        = "/local_path/centos-7.vmx"
  network_interfaces {
    virtual_network = "lab_dev"
  }
}

output "esxi_message" {
  description = "End message"
  value       = var.esxi_account
}
