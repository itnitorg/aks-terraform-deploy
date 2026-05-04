output "resource_group_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "location" {
  value = azurerm_resource_group.aks_rg.location
}
