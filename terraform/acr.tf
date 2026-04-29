# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  # ACR name must be globally unique and alphanumeric
  name                = "aksacr${replace(substr(random_pet.aksrandom.id, 0, 10), "-", "")}"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = true # Useful for pipeline authentication if needed
}

# Grant AcrPull permission to the AKS Kubelet Identity
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Output the ACR Login Server for the Pipeline
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
