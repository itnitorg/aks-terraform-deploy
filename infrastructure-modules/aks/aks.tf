# Documentation Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions
# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}



resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix          = var.resource_group_name
  location            = var.location
  name                = "${var.resource_group_name}-cluster"
  resource_group_name = var.resource_group_name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.resource_group_name}-nrg"


  default_node_pool {
    name                 = "systempool"
    vm_size              = "Standard_DS2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    #availability_zones   = [1, 2, 3]
    # Added June2023
    zones = [1, 2, 3]
    #enable_auto_scaling  = true # COMMENTED OCT2024
    auto_scaling_enabled = true # ADDED OCT2024
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  # Identity (System Assigned or Service Principal)
  identity { type = "SystemAssigned" }

  # Added June 2023
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }
  # Add On Profiles
  #  addon_profile {
  #    azure_policy { enabled = true }
  #    oms_agent {
  #      enabled                    = true
  #      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  #    }
  #  }

  # RBAC and Azure AD Integration Block
  #role_based_access_control {
  #  enabled = true
  #  azure_active_directory {
  #    managed                = true
  #    admin_group_object_ids = [azuread_group.aks_administrators.id]
  #  }
  #}  

  # Added June 2023
  azure_active_directory_role_based_access_control {
    #managed = true # COMMENTED OCT2024
    #admin_group_object_ids = [azuread_group.aks_administrators.id] # COMMENTED OCT2024
    admin_group_object_ids = [var.aks_admin_group_id] # ADDED OCT2024
  }

  # Windows Admin Profile
  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  # Network Profile
  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  # Added Oct 2024 - Secret Management
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  # AKS Cluster Tags 
  tags = {
    Environment = var.environment
  }


}
# Create Linux Azure AKS Node Pool

resource "azurerm_kubernetes_cluster_node_pool" "linux101" {
  #availability_zones    = [1, 2, 3]
  # Added June 2023
  zones = [1, 2, 3]
  #enable_auto_scaling  = true # COMMENTED OCT2024
  auto_scaling_enabled  = true # ADDED OCT2024
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "linux101"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = 30
  os_type               = "Linux" # Default is Linux, we can change to Windows
  vm_size               = "Standard_DS2_v2"
  priority              = "Regular" # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
}

# Create Windows Azure AKS Node Pool

resource "azurerm_kubernetes_cluster_node_pool" "win101" {
  #availability_zones    = [1, 2, 3]
  # Added June 2023
  zones = [1, 2, 3]
  #enable_auto_scaling  = true # COMMENTED OCT2024
  auto_scaling_enabled  = true # ADDED OCT2024
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "win101"
  temporary_name_for_rotation = "winrot"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = 35
  os_type               = "Windows" # Default is Linux, we can change to Windows
  vm_size               = "Standard_DS2_v2"
  priority              = "Regular" # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "windows"
    "app"           = "dotnet-apps"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "windows"
    "app"           = "dotnet-apps"
  }
}

# Create Linux Azure AKS Node Pool

resource "azurerm_kubernetes_cluster_node_pool" "linux102" {
  #availability_zones    = [1, 2, 3]
  # Added June 2023
  zones = [1, 2, 3]
  #enable_auto_scaling  = true # COMMENTED OCT2024
  auto_scaling_enabled  = true # ADDED OCT2024
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "linux102"
  temporary_name_for_rotation = "linrot102"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = 35
  os_type               = "Linux" # Default is Linux, we can change to Windows
  vm_size               = "Standard_DS2_v2"
  priority              = "Regular" # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "ui-app"        = "reactjs-apps"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "ui-app"        = "reactjs-apps"
  }
}
