include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../infrastructure-modules/security"
}

# Load the global env_vars so we can merge them
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

# Link to networking to get the real resource group name
dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    resource_group_name = "mock-rg-name"
    location            = "southafricanorth"
  }
}

# Pass the real outputs as inputs (overriding the global env.hcl defaults)
inputs = merge(
  local.env_vars.inputs,
  {
    resource_group_name = dependency.networking.outputs.resource_group_name
    location            = dependency.networking.outputs.location
  }
)
