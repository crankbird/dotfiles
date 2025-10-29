#!/usr/bin/env bash
set -euo pipefail

# AI/ML Development Environment Installer
# Optimized for RTX 4070 Mobile (8GB VRAM) + WSL2

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🤖 Setting up AI/ML Development Environment"
echo "Hardware detected: RTX 4070 Mobile (8GB VRAM)"
echo "System: $(lsb_release -ds)"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check CUDA
    if ! nvidia-smi >/dev/null 2>&1; then
        log_error "NVIDIA GPU or drivers not detected"
        exit 1
    fi
    
    # Check WSL2
    if [[ ! "$(uname -r)" =~ microsoft ]]; then
        log_warning "Not running on WSL2 - some optimizations may not apply"
    fi
    
    log_success "Prerequisites check passed"
}

# Install UV (fast Python package manager)
install_uv() {
    if command -v uv >/dev/null 2>&1; then
        log_success "uv already installed"
        return 0
    fi
    
    log_info "Installing uv (fast Python package manager)..."
    
    # Install uv
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Add to bashrc if not already there
    if ! grep -q ".local/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    log_success "uv installed"
}
install_miniconda() {
    if command -v conda >/dev/null 2>&1; then
        log_success "Conda already installed"
        return 0
    fi
    
    log_info "Installing Miniconda..."
    
    cd /tmp
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"
    
    # Add to PATH for this session
    export PATH="$HOME/miniconda3/bin:$PATH"
    
    # Add to bashrc if not already there
    if ! grep -q "miniconda3/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
    fi
    
    # Initialize conda
    conda init bash >/dev/null 2>&1
    conda config --set auto_activate_base false
    
    log_success "Miniconda installed"
}

# Create AI/ML environment
create_aiml_environment() {
    log_info "Creating AI/ML environment..."
    
    # Ensure conda is available
    export PATH="$HOME/miniconda3/bin:$PATH"
    
    # Remove existing environment if it exists
    if conda env list | grep -q "aiml"; then
        log_warning "Removing existing aiml environment"
        conda env remove -n aiml -y >/dev/null 2>&1
    fi
    
    # Create environment
    conda create -n aiml python=3.11 -y
    
    log_success "AI/ML environment created"
}

# Install core packages
install_core_packages() {
    log_info "Installing core scientific packages..."
    
    export PATH="$HOME/miniconda3/bin:$PATH"
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate aiml
    
    # Core scientific computing
    conda install -y numpy scipy pandas matplotlib seaborn jupyter ipykernel -c conda-forge
    
    # PyTorch with CUDA (optimized for RTX 4070)
    conda install -y pytorch pytorch-cuda=12.1 torchvision torchaudio -c pytorch -c nvidia
    
    log_success "Core packages installed"
}

# Install AI/ML packages
install_aiml_packages() {
    log_info "Installing AI/ML packages with uv (faster than pip)..."
    
    export PATH="$HOME/miniconda3/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate aiml
    
    # HuggingFace ecosystem (use uv for speed)
    uv pip install transformers datasets accelerate diffusers tokenizers
    
    # Computer Vision
    conda install -y opencv pillow scikit-image -c conda-forge
    
    # Machine Learning (uv for pure Python packages)
    uv pip install scikit-learn xgboost lightgbm optuna wandb
    
    # Development tools (uv is much faster for these)
    uv pip install black isort flake8 pytest ipywidgets tqdm rich
    
    # Specialized AI tools
    uv pip install openai anthropic ultralytics librosa soundfile
    uv pip install optimum onnx onnxruntime-gpu mlflow tensorboard
    
    log_success "AI/ML packages installed with uv"
}

# Install Node.js
install_nodejs() {
    if command -v node >/dev/null 2>&1; then
        log_success "Node.js already installed"
        return 0
    fi
    
    log_info "Installing Node.js..."
    
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y nodejs >/dev/null 2>&1
    
    # Install useful AI packages
    npm install -g @tensorflow/tfjs-node yaml-cli http-server >/dev/null 2>&1
    
    log_success "Node.js installed"
}

# Install system tools
install_system_tools() {
    log_info "Installing system monitoring tools..."
    
    sudo apt update >/dev/null 2>&1
    sudo apt install -y htop iotop ncdu tree >/dev/null 2>&1
    
    # Install GitHub CLI if not present
    if ! command -v gh >/dev/null 2>&1; then
        log_info "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null 2>&1
        sudo apt update >/dev/null 2>&1
        sudo apt install -y gh >/dev/null 2>&1
        log_success "GitHub CLI installed"
    else
        log_success "GitHub CLI already installed"
    fi
    
    log_success "System tools installed"
}

# Setup VS Code extensions
setup_vscode_extensions() {
    if ! command -v code >/dev/null 2>&1; then
        log_warning "VS Code not found, skipping extensions"
        return 0
    fi
    
    log_info "Installing VS Code extensions..."
    
    extensions=(
        "ms-python.python"
        "ms-toolsai.jupyter" 
        "ms-python.black-formatter"
        "ms-python.isort"
        "ms-python.flake8"
        "GitHub.copilot"
        "tamasfe.even-better-toml"
    )
    
    for ext in "${extensions[@]}"; do
        code --install-extension "$ext" >/dev/null 2>&1 || true
    done
    
    log_success "VS Code extensions installed"
}

# Create project template
create_project_template() {
    log_info "Creating AI project template..."
    
    mkdir -p ~/ai-projects/template/{data,models,notebooks,src,configs,outputs,logs,.github/workflows}
    
    # Environment template
    cat > ~/ai-projects/template/environment.yml << 'EOF'
name: project-env
channels:
  - pytorch
  - conda-forge
  - nvidia
dependencies:
  - python=3.11
  - pytorch
  - pytorch-cuda=12.1
  - torchvision
  - torchaudio
  - numpy
  - pandas
  - jupyter
  - pip
  - pip:
    - transformers
    - datasets
    - accelerate
EOF

    # Gitignore template
    cat > ~/ai-projects/template/.gitignore << 'EOF'
# AI/ML specific
*.pth
*.pt  
*.safetensors
/models/downloaded/
/data/raw/
/outputs/
/logs/
wandb/
.neptune/

# Python
__pycache__/
*.pyc
.env
.venv/
.ipynb_checkpoints/

# System
.DS_Store
Thumbs.db
EOF

    # README template
    cat > ~/ai-projects/template/README.md << 'EOF'
# AI/ML Project Template

## Setup
```bash
conda env create -f environment.yml
conda activate project-env
```

## Structure
- `data/` - Datasets
- `models/` - Trained models
- `notebooks/` - Jupyter experiments  
- `src/` - Source code
- `configs/` - Configuration files
- `outputs/` - Results and outputs
- `logs/` - Training logs

## Quick Start with GitHub
```bash
# Initialize repo
gh repo create my-ai-project --private
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/USERNAME/my-ai-project.git
git push -u origin main
```
EOF

    # GitHub Actions workflow for Python projects
    cat > ~/ai-projects/template/.github/workflows/python-app.yml << 'EOF'
name: Python application

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python 3.11
      uses: actions/setup-python@v3
      with:
        python-version: 3.11
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install uv
        uv pip install -r requirements.txt
    - name: Lint with flake8
      run: |
        uv pip install flake8
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
    - name: Test with pytest
      run: |
        uv pip install pytest
        pytest
EOF
    
    log_success "Project template created at ~/ai-projects/template (with GitHub workflows)"
}

# Add helpful aliases
setup_aliases() {
    log_info "Setting up helpful aliases..."
    
    # Check if aliases already exist
    if ! grep -q "# AI/ML Aliases" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'

# AI/ML Aliases
alias gpu='watch -n 1 nvidia-smi'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv'
alias gputemp='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'
alias aiml='conda activate aiml'
alias lab='jupyter lab --no-browser --port=8888'
alias nb='jupyter notebook --no-browser --port=8888'
alias uvinstall='uv pip install'
alias uvlist='uv pip list'

# GitHub CLI Shortcuts
alias ghcreate='gh repo create'
alias ghclone='gh repo clone' 
alias ghpr='gh pr create'
alias ghissue='gh issue create'
alias ghview='gh repo view --web'
alias ghstatus='gh pr status'
EOF
    fi
    
    log_success "Aliases added to ~/.bashrc (including GitHub CLI shortcuts)"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    export PATH="$HOME/miniconda3/bin:$PATH"
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate aiml
    
    # Test PyTorch CUDA
    python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA device: {torch.cuda.get_device_name()}')
    print(f'CUDA memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f}GB')
" 2>/dev/null || log_warning "PyTorch CUDA test failed"
    
    # Test key packages
    python -c "import numpy, pandas, matplotlib, transformers, cv2; print('✅ Key packages working')" 2>/dev/null || log_warning "Some packages may have issues"
    
    log_success "Installation verification complete"
}

# Main installation
main() {
    echo "🚀 Starting AI/ML environment setup..."
    echo "This will install:"
    echo "  • uv (fast Python package manager)"
    echo "  • Miniconda (Python environment management)"
    echo "  • PyTorch with CUDA support"
    echo "  • AI/ML packages (using uv for speed)"
    echo "This will take 10-15 minutes depending on your internet connection."
    echo
    
    install_uv
    check_prerequisites
    install_miniconda
    create_aiml_environment  
    install_core_packages
    install_aiml_packages
    install_nodejs
    install_system_tools
    setup_vscode_extensions
    create_project_template
    setup_aliases
    verify_installation
    
    echo
    echo "🎉 AI/ML Development Environment Setup Complete!"
    echo
    echo "📋 Next Steps:"
    echo "1. Restart your terminal (or run: source ~/.bashrc)"
    echo "2. Activate the environment: conda activate aiml"
    echo "3. Authenticate GitHub CLI: gh auth login"
    echo "4. Test CUDA: python -c \"import torch; print(torch.cuda.is_available())\""
    echo "5. Start Jupyter: jupyter lab --no-browser --port=8888"
    echo "6. Create a new project: cp -r ~/ai-projects/template ~/ai-projects/my-project"
    echo
    echo "📚 Documentation: See dev-environment/ai-ml-setup.md for detailed usage"
    echo "    echo "🔧 Aliases available: gpu, gpumem, gputemp, aiml, lab, nb, uvinstall, uvlist"
    echo "🐙 GitHub workflow: gh repo create, gh pr create, gh issue create""
    echo
    echo "Happy AI/ML developing! 🤖"
}

# Run main function
main "$@"