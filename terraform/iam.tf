# Create Entra ID Group in Azure AD for AKS Admins
resource "azuread_group" "aks_administrators" {
  #name        = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
  # Below two lines added as part of update June2023
  display_name     = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
  security_enabled = true
  description      = "Azure AKS Kubernetes administrators for the ${azurerm_resource_group.aks_rg.name}-cluster."
}



