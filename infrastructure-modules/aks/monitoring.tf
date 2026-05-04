# Create Random Pet Resource for Log Analytics Workspace Name
resource "random_pet" "aksrandom" {}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "${var.environment}-logs-${random_pet.aksrandom.id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = 30
}
