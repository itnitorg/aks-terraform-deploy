output "keyvault_id" {
  value       = azurerm_key_vault.keyvault.id
  description = "The ID of the Key Vault"
}

output "keyvault_name" {
  value       = azurerm_key_vault.keyvault.name
  description = "The name of the Key Vault"
}

output "aks_admin_group_object_id" {
  value       = azuread_group.aks_administrators.id
  description = "The Object ID of the Azure AD Group for AKS Admins"
}