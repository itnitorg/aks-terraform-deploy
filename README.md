# GitOps Multi-Environment Deployment with Terragrunt, OpenTofu & GitHub Actions

This repository provides a production-grade, "Zero-Blast-Radius" automation framework for provisioning Azure Kubernetes Service (AKS) clusters and deploying containerized applications. It utilizes a highly scalable modular architecture powered by OpenTofu, Terragrunt, Helm, and GitHub Actions.

## 🏗️ Project Structure

The infrastructure has been completely decoupled into reusable blueprints and environment-specific live states.

```text
.
├── .github/workflows/         # GitHub Actions CI/CD pipelines
│   ├── infrastructure.yml     # Automated Terragrunt provisioning (Networking, Security, AKS)
│   └── deployment.yml         # App deployment (Helm + Kustomize)
├── infrastructure-modules/    # Reusable OpenTofu Blueprints (The "How")
│   ├── networking/            # Virtual Networks, Resource Groups
│   ├── security/              # Key Vaults, Identity, AD Groups
│   └── aks/                   # AKS Cluster, Nodepools, Log Analytics
├── infrastructure-live/       # Live Environment State (The "What")
│   ├── root.hcl               # Master configuration & state backend bootstrapping
│   ├── dev/                   # Dev Environment
│   │   ├── env.hcl            # Dev variables
│   │   ├── networking/        # Dev Networking state
│   │   ├── security/          # Dev Security state
│   │   └── aks/               # Dev AKS state
│   └── prod/                  # Prod Environment
├── charts/                    # Helm charts for application stack
│   └── aks-app-stack/         # Unified application chart
├── kustomize/                 # Kustomize overlays
│   ├── base/                  # Base manifests
│   └── overlays/              # Environment-specific overlays
└── README.md
```

## 🚀 Getting Started

### Prerequisites
1.  **Azure Subscription**: Contributor access required.
2.  **GitHub Secrets**: Configure `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `SSH_PUBLIC_KEY`.
3.  **OIDC Federation**: Your Azure Service Principal must have federated credentials configured for this repository.

### Setup Guide
Simply clone the repository and let GitHub Actions do the heavy lifting. The `infrastructure.yml` pipeline will automatically install Terragrunt, evaluate the dependency graph, and sequentially provision Networking, Security, and the AKS cluster.

## 🏛️ Architecture Highlights

### 1. Zero-Blast-Radius Design
By breaking the infrastructure down into modular components (`networking`, `security`, `aks`), a change in a security policy will no longer require a plan calculation across the entire AKS cluster. Terragrunt orchestrates these modules by securely passing outputs (like the Key Vault ID) down the dependency graph.

### 2. Automated State Management
State files are automatically partitioned in Azure Blob Storage. The `root.hcl` file generates a dynamic backend key based on the folder path (e.g., `dev/networking/terraform.tfstate`), completely eliminating state collisions between environments.

## 🛠️ CI/CD Workflows

### 1. Infrastructure Provisioning (`infrastructure.yml`)
Provisions the underlying Azure infrastructure dynamically:
- **Triggers**: Changes in `infrastructure-modules/` or `infrastructure-live/`.
- **Toolchain**: Automatically provisions the environment using OpenTofu and Terragrunt `run-all apply`.
- **Environments**: Executes independently across `dev` and `prod`.

### 2. Application Deployment (`deployment.yml`)
Deploys the application stack using Helm:
- **Triggers**: Changes in the `charts/` directory.
- **Workflow**: Packages the Helm chart, hardens external images by pushing them to the private GHCR, and performs `kubectl apply -k` using Kustomize.
- **Environments**: Sequential deployment from `dev` to `prod`.

---
*Maintained by the Platform Engineering Team.*
