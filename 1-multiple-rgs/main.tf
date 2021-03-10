# Lets create multiple RGs with a foreach
# key = value
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}
resource "azurerm_resource_group" "rg" {
  for_each = {
    tf_test_one = "northeurope"
    tf_test_two = "northeurope"
  }
  name     = each.key
  location = each.value
}