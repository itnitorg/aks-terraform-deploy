# AKS Multi-Environment Deployment with Terraform & GitHub Actions

This repository provides a production-grade automation framework for provisioning Azure Kubernetes Service (AKS) clusters and deploying containerized applications using Terraform, Helm, and GitHub Actions.

## 🏗️ Project Structure

```text
.
├── .github/workflows/       # GitHub Actions CI/CD pipelines
│   ├── infrastructure.yml   # Terraform provisioning (AKS, ACR, KV)
│   └── deployment.yml       # App deployment (Helm)
├── terraform/               # Infrastructure as Code (Terraform)
│   ├── aks.tf               # AKS Cluster and Nodepools
│   ├── providers.tf         # Terraform & Provider configuration
│   ├── main.tf              # Shared core resources (RG, Random ID)
│   └── ...                  # ACR, KeyVault, Monitoring, IAM
├── charts/                  # Helm charts for application stack
│   └── aks-app-stack/       # Unified application chart
├── kustomize/               # Base
│   └── base/                # overlays
│   └── overlays/ 
├── manifests/               # Raw Kubernetes manifests (reference)
└── README.md
```

## 🚀 Getting Started

### Prerequisites
1.  **Azure Subscription**: Contributor access required.
2.  **GitHub Secrets**: Configure `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `SSH_PUBLIC_KEY`.
3.  **OIDC Federation**: Set up Azure AD App Registration with federated credentials for this repository.

### Setup Guide
For detailed instructions on setting up the environment, Azure OIDC, and GitHub Actions, see the [GitHub Actions Setup Guide](.github/workflows/README.md).

## 🛠️ CI/CD Workflows

### 1. Infrastructure Provisioning (`infrastructure.yml`)
Provisions the underlying Azure infrastructure:
- **Triggers**: Changes in the `terraform/` directory.
- **Environments**: Deploys to `dev` automatically; requires manual approval for `prod`.
- **Resources**: AKS Cluster (System & User pools), Azure Container Registry, Key Vault, and Log Analytics.

### 2. Application Deployment (`deployment.yml`)
Deploys the application stack using Helm:
- **Triggers**: Changes in the `charts/` directory.
- **Workflow**: Packages the Helm chart, hardens external images by pushing them to the private ACR, and performs `helm upgrade`.
- **Environments**: Sequential deployment from `dev` to `prod`.

## 📜 Documentation
- [GitHub Actions Setup Guide](.github/workflows/README.md)

---
*Maintained by the DevOps Team.*

# Kustomize Added
