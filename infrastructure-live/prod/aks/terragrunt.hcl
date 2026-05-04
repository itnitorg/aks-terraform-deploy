include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load the same env_vars so we can merge them
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../infrastructure-modules/aks"
}

# 1. LINK TO NETWORKING
dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    resource_group_name = "mock-rg-name"
    location            = "southafricanorth"
  }
}

# 2. LINK TO SECURITY
dependency "security" {
  config_path = "../security"

  mock_outputs = {
    keyvault_name             = "mock-kv-name"
    keyvault_id               = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.KeyVault/vaults/mock"
    aks_admin_group_object_id = "00000000-0000-0000-0000-000000000000"
  }
}

# 3. PASS THE OUTPUTS AS INPUTS
inputs = merge(
  local.env_vars.inputs,
  {
    resource_group_name      = dependency.networking.outputs.resource_group_name
    location                 = dependency.networking.outputs.location
    key_vault_name           = dependency.security.outputs.keyvault_name
    key_vault_id             = dependency.security.outputs.keyvault_id
    aks_admin_group_id       = dependency.security.outputs.aks_admin_group_object_id
  }
)
