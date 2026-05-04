# Define Input Variables
# 1. Azure Location (southafricanorth)
# 2. Azure Resource Group Name 
# 3. Azure AKS Environment Name (Dev, QA, Prod)

# Azure Location
variable "location" {
  type        = string
  description = "Azure Region where all these resources will be provisioned"
  default     = "southafricanorth"
}

# Azure Resource Group Name
variable "resource_group_name" {
  type        = string
  description = "This variable defines the Resource Group"
  default     = "terraform-aks"
}

# Azure AKS Environment Name
variable "environment" {
  type        = string
  description = "This variable defines the Environment"
  #default = "dev2"
}




# Windows Admin Username for k8s worker nodes
variable "windows_admin_username" {
  type        = string
  default     = "azureuser"
  description = "This variable defines the Windows admin username k8s Worker nodes"
}

# Windows Admin Password for k8s worker nodes
variable "windows_admin_password" {
  type        = string
  default     = "StackSimplify@102"
  description = "This variable defines the Windows admin password k8s Worker nodes"
}

variable "ssh_public_key" {
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault"
}

variable "aks_admin_group_id" {
  type        = string
  description = "The Object ID of the Azure AD Group for AKS Admins"
}
