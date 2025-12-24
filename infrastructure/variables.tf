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
  default = "East US"
}

variable "vnet_name" {
  default = "vnet-homelab"
}
