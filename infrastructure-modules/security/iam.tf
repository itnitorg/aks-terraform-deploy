# Create Entra ID Group in Azure AD for AKS Admins
resource "azuread_group" "aks_administrators" {
  #name        = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
  # Below two lines added as part of update June2023
  display_name     = "${var.resource_group_name}-cluster-administrators"
  security_enabled = true
  description      = "Azure AKS Kubernetes administrators for the ${var.resource_group_name}-cluster."
}



