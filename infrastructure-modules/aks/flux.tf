# infrastructure-modules/aks/flux.tf



# Bootstrap Flux into the AKS cluster
resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "clusters/${var.environment}"

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}
