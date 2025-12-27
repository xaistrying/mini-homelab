locals {
  common_tags = {
    Environment = "lab"
    Project     = "mini-homelab"
    Owner       = "xaistrying"
  }
}

variable "resource_group_name" {
  default = "rg-homelab"
}

variable "location" {
  default = "Central India"
}

variable "vnet_name" {
  default = "vnet-homelab"
}

variable "ssh_public_key" {
  description = "Public SSH Key for VMs"
  type        = string
}

variable "admin_username" {
  default = "xaistrying"
}

variable "vm_gateway_size" {
  default = "Standard_B2ats_v2"
}

variable "vm_app_size" {
  default = "Standard_B2as_v2"
}
