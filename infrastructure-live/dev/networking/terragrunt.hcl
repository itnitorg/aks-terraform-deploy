include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../infrastructure-modules/networking"
}

# Inputs are inherited globally from env.hcl
inputs = {}
