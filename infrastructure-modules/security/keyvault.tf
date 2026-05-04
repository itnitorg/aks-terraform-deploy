# Create Azure Key Vault
data "azurerm_client_config" "current" {}

resource "random_pet" "aksrandom" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = "kv${var.environment}${replace(substr(random_pet.aksrandom.id, 0, 8), "-", "")}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# Access Policy for the Terraform User (The GitHub Robot)
resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

# The AKS access policy has been moved to the AKS module to avoid circular dependencies.

# Wait for the access policy to be fully applied before creating secrets
resource "time_sleep" "wait_for_policy" {
  depends_on = [azurerm_key_vault_access_policy.terraform_user]
  create_duration = "30s"
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Example Secret
resource "azurerm_key_vault_secret" "app_password" {
  name         = "app-db-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.keyvault.id

  # Wait for the sleep to finish
  depends_on = [
    time_sleep.wait_for_policy
  ]
}
