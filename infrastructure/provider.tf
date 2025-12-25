terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
  cloud {
    organization = "xaistrying-org"
    workspaces {
      name = "mini-homelab"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "9ae4f01a-d08f-4f41-aa90-dc5c7a6e2765"
}
