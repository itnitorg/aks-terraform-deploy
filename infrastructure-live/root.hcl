# 0. LOAD ENVIRONMENT VARIABLES
locals {
  # This version won't crash if the file is missing (like when running from root)
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "empty.hcl"), { inputs = {} })
}

# 1. GENERATE THE REMOTE STATE CONFIG
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "terraform-storage-rg"
    storage_account_name = "tfstatenew2026dev" # New globally unique name for the new subscription
    container_name       = "tfstatefiles"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

# 2. GENERATE GLOBAL PROVIDER CONFIG
generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

# 3. GLOBAL INPUTS
inputs = local.env_vars.inputs
