data "azurerm_client_config" "current" {}

# Role Assignment for AKS Key Vault Secrets Provider Identity
resource "azurerm_role_assignment" "aks_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
}
