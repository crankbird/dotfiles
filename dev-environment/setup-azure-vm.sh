#!/usr/bin/env bash
set -euo pipefail

# Azure Development VM Setup
# Uses existing dotfiles infrastructure for consistent environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

VM_NAME="crank-dev-vm"
RESOURCE_GROUP="crank-platform"
VM_USER="johnr"

echo "☁️ Setting up Azure Development VM..."
echo "🎯 Using existing dotfiles infrastructure"

# Get VM IP
get_vm_ip() {
    local ip=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)
    echo "$ip"
}

# Copy dotfiles to VM
setup_vm_environment() {
    local vm_ip=$(get_vm_ip)
    echo "📦 Setting up development environment on VM: $vm_ip"
    
    # Copy dotfiles to VM
    echo "📁 Copying dotfiles to VM..."
    scp -r -o StrictHostKeyChecking=no "$DOTFILES_ROOT" "$VM_USER@$vm_ip:~/dotfiles"
    
    # Run the installation remotely
    echo "🚀 Running dotfiles installation on VM..."
    ssh -o StrictHostKeyChecking=no "$VM_USER@$vm_ip" << 'EOF'
# Update system first
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git vim nano htop tree jq unzip build-essential

# Run dotfiles installation
cd ~/dotfiles
chmod +x install.sh
./install.sh

# Install development environment
chmod +x dev-environment/install-containers.sh
./dev-environment/install-containers.sh

# Install multi-cloud tools (includes Azure CLI, Terraform, etc.)
chmod +x dev-environment/install-multi-cloud.sh
./dev-environment/install-multi-cloud.sh

# Create projects directory
mkdir -p ~/projects

echo "✅ Development environment setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Configure Git: git config --global user.name 'Your Name'"
echo "2. Configure Git: git config --global user.email 'your.email@example.com'"  
echo "3. Set up SSH key for GitHub: ssh-keygen -t ed25519 -C 'your.email@example.com'"
echo "4. Clone your repositories to ~/projects/"
echo "5. Connect VS Code Remote"
EOF

    echo "✅ VM setup complete!"
    echo ""
    echo "🔌 VS Code Remote Setup:"
    echo "1. Install 'Remote - SSH' extension in VS Code"
    echo "2. Add SSH configuration:"
    echo ""
    echo "   Host crank-dev"
    echo "       HostName $vm_ip"
    echo "       User $VM_USER"
    echo "       IdentityFile ~/.ssh/id_rsa"
    echo ""
    echo "3. Connect to 'crank-dev' in VS Code"
    echo "4. Open ~/projects folder"
}

# Main function
main() {
    # Check if VM exists
    if ! az vm show -g $RESOURCE_GROUP -n $VM_NAME >/dev/null 2>&1; then
        echo "❌ VM $VM_NAME not found in resource group $RESOURCE_GROUP"
        echo "Create it first with:"
        echo "az vm create --resource-group $RESOURCE_GROUP --name $VM_NAME --image Ubuntu2204 --admin-username $VM_USER --generate-ssh-keys"
        exit 1
    fi
    
    setup_vm_environment
}

main "$@"