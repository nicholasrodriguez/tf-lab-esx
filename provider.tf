provider "esxi" {
  esxi_hostname = "esx02"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = var.esxi_account
  esxi_password = var.LAB_PW
}

provider "fakewebservices" {}
