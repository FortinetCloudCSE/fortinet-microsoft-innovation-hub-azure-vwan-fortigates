terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4"
    }
    fortiflexvm = {
      source  = "fortinetdev/fortiflexvm"
      version = "~>2"
    }
  }
  required_version = ">= 1"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "fortiflexvm" {
}
