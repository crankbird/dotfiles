#!/usr/bin/env bash
set -euo pipefail

# AI/ML Development Environment Setup - Pure uv approach
# Optimized for RTX 4070 Mobile (8GB VRAM)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🤖 Setting up AI/ML development environment..."
echo "📍 Using pure uv approach (no conda conflicts)"

# Install uv if not present
install_uv() {
    if command -v uv >/dev/null 2>&1; then
        echo "✅ uv is already installed"
        uv --version
    else
        echo "📦 Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
        echo "✅ uv installed successfully"
    fi
}

# Install Node.js and Graphite
install_nodejs_graphite() {
    # Install Node.js if not present
    if ! command -v node >/dev/null 2>&1; then
        echo "📦 Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        echo "✅ Node.js is already installed: $(node --version)"
    fi

    # Install Graphite
    if command -v gt >/dev/null 2>&1; then
        echo "✅ Graphite is already installed"
        gt --version
    else
        echo "📦 Installing Graphite CLI..."
        npm install -g @withgraphite/graphite-cli
        echo "✅ Graphite installed successfully"
    fi
}

# Create Python environment with AI/ML packages
setup_aiml_env() {
    echo "🐍 Setting up AI/ML Python environment..."
    
    cd "$DOTFILES_ROOT"
    
    # Remove any existing venv
    if [ -d ".venv" ]; then
        echo "🧹 Removing existing virtual environment..."
        rm -rf .venv
    fi
    
    # Create new environment
    echo "📦 Creating Python 3.11 virtual environment..."
    uv venv --python 3.11
    
    # Install packages
    echo "⚡ Installing AI/ML packages with CUDA support..."
    source .venv/bin/activate
    uv pip install --index-strategy unsafe-best-match --extra-index-url https://download.pytorch.org/whl/cu121 -r requirements-aiml.txt
    
    echo "✅ AI/ML environment setup complete!"
}

# Test CUDA functionality
test_cuda() {
    echo "🧪 Testing CUDA functionality..."
    
    cd "$DOTFILES_ROOT"
    source .venv/bin/activate
    
    python -c "
import torch
print('🔥 PyTorch version:', torch.__version__)
print('🚀 CUDA available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('💎 CUDA device:', torch.cuda.get_device_name(0))
    print('💾 CUDA memory:', round(torch.cuda.get_device_properties(0).total_memory / 1e9, 2), 'GB')
    print('⚡ CUDA version:', torch.version.cuda)
    print('✅ GPU acceleration ready!')
else:
    print('❌ CUDA not available - CPU only mode')
"
}

# Create activation script
create_activation_script() {
    echo "📝 Creating environment activation script..."
    
    cat > "$DOTFILES_ROOT/activate-aiml.sh" << 'EOF'
#!/bin/bash
# AI/ML Environment Activation Script

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🤖 Activating AI/ML environment..."
cd "$DOTFILES_ROOT"
source .venv/bin/activate

echo "✅ Environment activated!"
echo "📦 Available packages:"
echo "   - PyTorch $(python -c 'import torch; print(torch.__version__)')"
echo "   - Transformers, Datasets, Diffusers"
echo "   - OpenCV, Pillow, ImageIO" 
echo "   - Jupyter Lab, Matplotlib, Seaborn"
echo "   - Black, Ruff, Pytest, MyPy"
echo ""
echo "🚀 Quick start:"
echo "   python -c 'import torch; print(\"CUDA:\", torch.cuda.is_available())'"
echo "   jupyter lab  # Start Jupyter Lab"
echo "   gt --help    # Graphite workflow commands"
EOF
    
    chmod +x "$DOTFILES_ROOT/activate-aiml.sh"
    echo "✅ Created activation script: activate-aiml.sh"
}

# Main installation
main() {
    echo "🎯 Starting AI/ML environment setup..."
    echo
    
    install_uv
    install_nodejs_graphite
    setup_aiml_env
    test_cuda
    create_activation_script
    
    echo
    echo "🎉 AI/ML environment setup complete!"
    echo
    echo "🚀 Usage:"
    echo "   cd $DOTFILES_ROOT"
    echo "   source activate-aiml.sh    # Activate environment"
    echo "   ./dev-environment/check-env.sh  # Check status"
    echo
    echo "💡 Tips for RTX 4070 (8GB VRAM):"
    echo "   - Use batch_size=1-4 for training"
    echo "   - Use mixed precision: torch.cuda.amp"
    echo "   - Monitor memory: torch.cuda.memory_summary()"
    echo
    echo "📚 Workflow:"
    echo "   - Use 'gt' commands for stacked PRs"
    echo "   - See dev-environment/graphite-workflow.md"
}

# Run main function
main "$@"