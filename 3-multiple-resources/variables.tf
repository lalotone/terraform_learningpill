# Non-type defined variable.
# Type will be defined by the input variable.
variable "location" {}

# Some variables contains the type of the variable and the default value.
variable "prefix" {
  type    = string
  default = "my"
}

# Warning: The map is a group of strings. If the variable itself require multiple
# types, like booleans, strings, etc. an object should be used.
variable "tags" {
  type = map

  default = {
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "sku" {
  default = {
    westus2 = "16.04-LTS"
    eastus  = "18.04-LTS"
  }
}