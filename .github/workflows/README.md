# GitHub Actions Workflows – Setup Guide

## Prerequisites

| Requirement | Details |
|---|---|
| Azure Subscription | Active subscription with permissions to create AKS, ACR, Key Vault, AD Groups |
| GitHub Repository | This repo pushed to GitHub |
| Azure AD App Registration | With OIDC federated credentials for this GitHub repo |
| Terraform State Storage | Azure Storage Account `terraformstatexlrwdrza` in RG `terraform-storage-rg` |

---

## 1. Configure Azure OIDC Federation

GitHub Actions authenticates to Azure using **OpenID Connect (OIDC)** — no stored client secrets required.

### Create an App Registration

```bash
# Create the app registration
az ad app create --display-name "github-actions-aks-terraform"

# Note the appId (CLIENT_ID) from the output
# Create a service principal for it
az ad sp create --id <CLIENT_ID>

# Assign Contributor role on your subscription
az role assignment create \
  --assignee <CLIENT_ID> \
  --role Contributor \
  --scope /subscriptions/<SUBSCRIPTION_ID>

# Grant Directory.ReadWrite.All for Azure AD Group management
# (Required for 06-aks-administrators-azure-ad.tf)
# Go to Azure Portal → App Registrations → API Permissions → Add Permission
# → Microsoft Graph → Application → Directory.ReadWrite.All → Grant Admin Consent
```

### Add Federated Credentials

```bash
# For the 'main' branch
az ad app federated-credential create --id <APP_OBJECT_ID> --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<GITHUB_ORG>/<REPO_NAME>:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# For the 'dev' environment
az ad app federated-credential create --id <APP_OBJECT_ID> --parameters '{
  "name": "github-env-dev",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<GITHUB_ORG>/<REPO_NAME>:environment:dev",
  "audiences": ["api://AzureADTokenExchange"]
}'

# For the 'prod' environment
az ad app federated-credential create --id <APP_OBJECT_ID> --parameters '{
  "name": "github-env-prod",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<GITHUB_ORG>/<REPO_NAME>:environment:prod",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

---

## 2. Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret** and add:

| Secret Name | Value | Used By |
|---|---|---|
| `AZURE_CLIENT_ID` | App Registration Client (Application) ID | Both workflows |
| `AZURE_TENANT_ID` | Azure AD Tenant ID | Both workflows |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | Both workflows |
| `SSH_PUBLIC_KEY` | Contents of `aks-terraform-devops-ssh-key-ububtu.pub` | Terraform workflow |

### Generate SSH Key (if not already done)

```bash
ssh-keygen -m PEM -t rsa -b 4096 -C "azureuser@myserver" -f ~/aks-ssh-key -N ""
# Copy the contents of ~/aks-ssh-key.pub into the SSH_PUBLIC_KEY secret
cat ~/aks-ssh-key.pub | pbcopy
```

---

## 3. Configure GitHub Environments

Go to **Settings → Environments** and create:

### `dev` Environment
- No special protection rules needed (deploys automatically)

### `prod` Environment
- **Required reviewers**: Add yourself (or your team) as a required reviewer
- This creates a **manual approval gate** before production deployments
- Equivalent to Azure DevOps environment approval checks

---

## 4. Workflows

### `infrastructure.yml`
- **Triggers**: Push to `main` when `terraform/**` files change, or manual dispatch
- **Stages**: Validate → Deploy Dev → Deploy Prod (with approval)
- **Purpose**: Provisions AKS clusters, ACR, Key Vault, AD Groups via Terraform

### `deployment.yml`
- **Triggers**: Push to `main` when `charts/**` files change, or manual dispatch
- **Stages**: Package + Harden Images → Deploy Dev → Deploy Prod (with approval)
- **Purpose**: Deploys Helm chart to AKS clusters

---

## 5. Migrating from Azure DevOps

| Azure DevOps Concept | GitHub Actions Equivalent |
|---|---|
| Service Connection | OIDC federated credential + GitHub Secrets |
| Secure Files | GitHub Secrets (stored as string, written to file at runtime) |
| Pipeline Variables | `env:` block or GitHub Variables |
| `##vso[task.setvariable]` | `echo "key=value" >> $GITHUB_OUTPUT` |
| Pipeline Environments (approvals) | GitHub Environments (required reviewers) |
| `PublishPipelineArtifact@1` | `actions/upload-artifact@v4` |
| `DownloadPipelineArtifact@2` | `actions/download-artifact@v4` |
| `TerraformTask@5` | `hashicorp/setup-terraform@v3` + `terraform` CLI |
| `HelmDeploy@0` | `helm` CLI (pre-installed on ubuntu-latest) |
| `KubeloginInstaller@0` | `azure/use-kubelogin@v1` |
| `AzureCLI@2` | `azure/login@v2` + inline `az` commands |
