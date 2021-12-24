variable "esxi_account" {
  description = "Account used to access ESXi"
  type        = string
  default     = "root"
}

variable "LAB_PW" {
  description = "ESXi root PW from env TF_LAB_PW"
  type        = string
}

variable "LAB_DOMAIN" {
  description = "Domain of the lab from env TF_LAB_DOMAIN"
  type = string
}

variable "LAB_DNS1" {
  description = "First DNS server of the lab from env TF_LAB_DNS1"
  type = string
}

variable "LAB_DNS2" {
  description = "Second DNS server of the lab from env TF_LAB_DNS2"
  type = string
}

variable "LAB_REPO" {
  description = "Domain of the lab from env TF_LAB_REPO"
  type = string
}

variable "LAB_SUBNET" {
  description = "Subnet of the lab from env TF_LAB_SUBNET"
  type = string
}

variable "LAB_USER" {
  description = "Non root user of the lab from env TF_LAB_USER"
  type = string
}

variable "vms" {
  description = "List of VMs to be managed"
  type        = list(string)
  default     = [
    "lvm05",
    "lvm06",
    "lvm07",
  ]
}
