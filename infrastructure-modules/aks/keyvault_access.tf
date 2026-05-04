data "azurerm_client_config" "current" {}

# Access Policy for AKS Key Vault Secrets Provider Identity
resource "azurerm_key_vault_access_policy" "aks_identity" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id

  secret_permissions = [
    "Get", "List"
  ]
}
