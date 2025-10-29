#!/usr/bin/env bash
set -euo pipefail

# Multi-Cloud Infrastructure Setup - Azure First
# Designed for replication across GCP, AWS, Oracle, and GPU providers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

echo "☁️ Setting up multi-cloud infrastructure tools..."
echo "🎯 Starting with Azure, designed for cloud portability"

# Install Azure CLI
install_azure_cli() {
    if command -v az >/dev/null 2>&1; then
        echo "✅ Azure CLI already installed: $(az version --query '"azure-cli"' -o tsv)"
    else
        echo "📦 Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        echo "✅ Azure CLI installed"
    fi
}

# Install Terraform
install_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        echo "✅ Terraform already installed: $(terraform version | head -1)"
    else
        echo "📦 Installing Terraform..."
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform
        echo "✅ Terraform installed"
    fi
}

# Install Ansible
install_ansible() {
    if command -v ansible >/dev/null 2>&1; then
        echo "✅ Ansible already installed: $(ansible --version | head -1)"
    else
        echo "📦 Installing Ansible..."
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install -y ansible
        echo "✅ Ansible installed"
    fi
}

# Install cloud CLIs for future use
install_other_cloud_tools() {
    echo "📦 Installing other cloud provider tools..."
    
    # Google Cloud CLI
    if ! command -v gcloud >/dev/null 2>&1; then
        echo "📦 Installing Google Cloud CLI..."
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update && sudo apt-get install -y google-cloud-cli
    else
        echo "✅ Google Cloud CLI already installed"
    fi
    
    # AWS CLI
    if ! command -v aws >/dev/null 2>&1; then
        echo "📦 Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    else
        echo "✅ AWS CLI already installed"
    fi
    
    # OCI CLI (Oracle Cloud)
    if ! command -v oci >/dev/null 2>&1; then
        echo "📦 Installing Oracle Cloud CLI..."
        bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    else
        echo "✅ Oracle Cloud CLI already installed"
    fi
}

# Setup SSH keys if not present
setup_ssh_keys() {
    echo "🔐 Setting up SSH keys..."
    
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        echo "📝 Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_rsa -N ""
        echo "✅ SSH key generated: ~/.ssh/id_rsa.pub"
    else
        echo "✅ SSH key already exists"
    fi
    
    # Display public key for cloud provider setup
    echo ""
    echo "📋 Your SSH public key (add this to cloud providers):"
    echo "----------------------------------------"
    cat ~/.ssh/id_rsa.pub
    echo "----------------------------------------"
}

# Create multi-cloud Terraform structure
create_terraform_structure() {
    echo "🏗️ Creating multi-cloud Terraform structure..."
    
    INFRA_DIR="$DOTFILES_ROOT/infrastructure"
    mkdir -p "$INFRA_DIR"/{modules,environments/{dev,staging,prod},providers/{azure,gcp,aws,oracle}}
    
    # Shared modules
    mkdir -p "$INFRA_DIR/modules"/{kubernetes,networking,databases,monitoring,ai-ml}
    
    # Azure-specific Terraform
    cat > "$INFRA_DIR/providers/azure/main.tf" << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  
  tags = var.common_tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project_name}-${var.environment}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.project_name}-${var.environment}"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project_name, "-", "")}${var.environment}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = var.common_tags
}
EOF

    # Variables
    cat > "$INFRA_DIR/providers/azure/variables.tf" << 'EOF'
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ai-ml-platform"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "ai-ml-platform"
    ManagedBy   = "terraform"
  }
}
EOF

    # Outputs
    cat > "$INFRA_DIR/providers/azure/outputs.tf" << 'EOF'
output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].host
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "container_registry_url" {
  value = azurerm_container_registry.main.login_server
}
EOF

    # Environment-specific configs
    cat > "$INFRA_DIR/environments/dev/azure.tfvars" << 'EOF'
environment = "dev"
node_count  = 2
vm_size     = "Standard_D2s_v3"
location    = "East US"

common_tags = {
  Environment = "dev"
  Project     = "ai-ml-platform"
  ManagedBy   = "terraform"
  Owner       = "development-team"
}
EOF

    echo "✅ Terraform structure created"
}

# Create Ansible structure
create_ansible_structure() {
    echo "🔧 Creating Ansible automation..."
    
    ANSIBLE_DIR="$DOTFILES_ROOT/automation"
    mkdir -p "$ANSIBLE_DIR"/{playbooks,roles,inventory}
    
    # Convert your current setup to Ansible
    cat > "$ANSIBLE_DIR/playbooks/dev-environment.yml" << 'EOF'
---
- name: Setup AI/ML Development Environment
  hosts: localhost
  become: yes
  vars:
    dotfiles_repo: "https://github.com/crankbird/dotfiles.git"
    user_home: "{{ ansible_env.HOME }}"
    
  tasks:
    - name: Install system dependencies
      apt:
        name:
          - curl
          - wget
          - git
          - build-essential
          - python3-pip
          - nodejs
          - npm
          - docker.io
          - docker-compose
        state: present
        update_cache: yes

    - name: Add user to docker group
      user:
        name: "{{ ansible_user }}"
        groups: docker
        append: yes

    - name: Install uv (Python package manager)
      shell: curl -LsSf https://astral.sh/uv/install.sh | sh
      args:
        creates: "{{ user_home }}/.cargo/bin/uv"

    - name: Install Starship prompt
      shell: curl -sS https://starship.rs/install.sh | sh -s -- -y
      args:
        creates: /usr/local/bin/starship

    - name: Clone dotfiles repository
      git:
        repo: "{{ dotfiles_repo }}"
        dest: "{{ user_home }}/projects/dotfiles"
        update: yes
      become_user: "{{ ansible_user }}"

    - name: Run dotfiles installer
      shell: "{{ user_home }}/projects/dotfiles/install.sh"
      become_user: "{{ ansible_user }}"

    - name: Setup AI/ML environment
      shell: "{{ user_home }}/projects/dotfiles/dev-environment/install-aiml-uv.sh"
      become_user: "{{ ansible_user }}"
EOF

    # Cloud deployment playbook
    cat > "$ANSIBLE_DIR/playbooks/cloud-deploy.yml" << 'EOF'
---
- name: Deploy to Kubernetes
  hosts: localhost
  vars:
    namespace: "{{ environment | default('dev') }}"
    
  tasks:
    - name: Create namespace
      kubernetes.core.k8s:
        name: "{{ namespace }}"
        api_version: v1
        kind: Namespace
        state: present

    - name: Deploy applications with Helm
      kubernetes.core.helm:
        name: "{{ app_name }}"
        chart_ref: "./helm/{{ app_name }}"
        release_namespace: "{{ namespace }}"
        values:
          image:
            tag: "{{ image_tag | default('latest') }}"
          environment: "{{ environment }}"
EOF

    echo "✅ Ansible structure created"
}

# Create deployment scripts
create_deployment_scripts() {
    echo "📝 Creating deployment automation..."
    
    # Azure deployment script
    cat > "$DOTFILES_ROOT/deploy-azure.sh" << 'EOF'
#!/bin/bash
# Deploy to Azure with Terraform + Ansible

set -euo pipefail

ENVIRONMENT=${1:-dev}

echo "🚀 Deploying to Azure ($ENVIRONMENT environment)..."

# Login to Azure
az login

# Initialize and apply Terraform
cd infrastructure/providers/azure
terraform init
terraform plan -var-file="../../environments/$ENVIRONMENT/azure.tfvars"
terraform apply -var-file="../../environments/$ENVIRONMENT/azure.tfvars" -auto-approve

# Get AKS credentials
CLUSTER_NAME=$(terraform output -raw cluster_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# Deploy applications with Ansible
cd ../../../automation
ansible-playbook playbooks/cloud-deploy.yml -e environment=$ENVIRONMENT

echo "✅ Deployment complete!"
kubectl get nodes
kubectl get pods --all-namespaces
EOF
    chmod +x "$DOTFILES_ROOT/deploy-azure.sh"

    # Multi-cloud deployment wrapper
    cat > "$DOTFILES_ROOT/deploy-multi-cloud.sh" << 'EOF'
#!/bin/bash
# Deploy to multiple cloud providers

PROVIDER=${1:-azure}
ENVIRONMENT=${2:-dev}

case $PROVIDER in
    azure)
        ./deploy-azure.sh $ENVIRONMENT
        ;;
    gcp)
        ./deploy-gcp.sh $ENVIRONMENT
        ;;
    aws)
        ./deploy-aws.sh $ENVIRONMENT
        ;;
    oracle)
        ./deploy-oracle.sh $ENVIRONMENT
        ;;
    *)
        echo "❌ Unsupported provider: $PROVIDER"
        echo "Supported: azure, gcp, aws, oracle"
        exit 1
        ;;
esac
EOF
    chmod +x "$DOTFILES_ROOT/deploy-multi-cloud.sh"

    echo "✅ Deployment scripts created"
}

# Main installation
main() {
    echo "🎯 Setting up multi-cloud infrastructure automation..."
    echo
    
    install_azure_cli
    install_terraform
    install_ansible
    install_other_cloud_tools
    setup_ssh_keys
    create_terraform_structure
    create_ansible_structure
    create_deployment_scripts
    
    echo
    echo "🎉 Multi-cloud infrastructure setup complete!"
    echo
    echo "🚀 Next steps:"
    echo "1. Login to Azure: az login"
    echo "2. Deploy infrastructure: ./deploy-azure.sh dev"
    echo "3. Replicate to other clouds: ./deploy-multi-cloud.sh gcp dev"
    echo
    echo "📁 Structure created:"
    echo "   infrastructure/ - Terraform configs for all providers"
    echo "   automation/     - Ansible playbooks for deployment"
    echo "   deploy-*.sh     - Cloud-specific deployment scripts"
    echo
    echo "🔐 SSH Public Key (add to cloud providers):"
    cat ~/.ssh/id_rsa.pub
}

# Run main function
main "$@"