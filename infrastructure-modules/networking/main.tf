resource "random_pet" "aksrandom" {}

resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
}
