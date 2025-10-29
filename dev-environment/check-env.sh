#!/usr/bin/env bash
# Quick environment health check for AI/ML development

echo "🔍 AI/ML Development Environment Health Check"
echo "=============================================="
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_item() {
    if $1; then
        echo -e "${GREEN}✅ $2${NC}"
        return 0
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

warn_item() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

score=0
total=0

echo "🖥️  System Resources"
echo "-------------------"
# Memory check
mem_gb=$(free -g | awk '/^Mem:/{print $2}')
((total++))
if [[ $mem_gb -ge 15 ]]; then
    check_item true "RAM: ${mem_gb}GB (Excellent for AI/ML)"
    ((score++))
else
    check_item false "RAM: ${mem_gb}GB (Minimum 16GB recommended)"
fi

# GPU check
((total++))
if nvidia-smi >/dev/null 2>&1; then
    gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits)
    gpu_mem=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
    check_item true "GPU: $gpu_name (${gpu_mem}MB VRAM)"
    ((score++))
else
    check_item false "GPU: NVIDIA GPU not detected"
fi

echo
echo "🐍 Python Environment"
echo "---------------------"
# Python version
((total++))
if python3 --version 2>/dev/null | grep -q "3.1[12]"; then
    py_version=$(python3 --version | cut -d' ' -f2)
    check_item true "Python: $py_version (Recommended for AI/ML)"
    ((score++))
else
    py_version=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "Not found")
    check_item false "Python: $py_version (Python 3.11+ recommended)"
fi

# Conda
((total++))
if command -v conda >/dev/null 2>&1; then
    conda_version=$(conda --version | cut -d' ' -f2)
    check_item true "Conda: $conda_version"
    ((score++))
else
    check_item false "Conda: Not installed (recommended for AI/ML)"
fi

# AI/ML Environment
((total++))
export PATH="$HOME/miniconda3/bin:$PATH"
if command -v conda >/dev/null 2>&1 && conda env list | grep -q "aiml"; then
    check_item true "AI/ML Environment: Available (aiml)"
    ((score++))
else
    check_item false "AI/ML Environment: Not found"
fi

echo
echo "🤖 AI/ML Packages"
echo "-----------------"
# Check if in conda environment
if [[ "$CONDA_DEFAULT_ENV" == "aiml" ]] || [[ "$CONDA_PREFIX" == *"aiml"* ]]; then
    env_active=true
else
    env_active=false
    if command -v conda >/dev/null 2>&1; then
        source ~/miniconda3/etc/profile.d/conda.sh 2>/dev/null || true
        conda activate aiml 2>/dev/null || true
    fi
fi

# PyTorch
((total++))
if python -c "import torch; print(torch.__version__)" 2>/dev/null; then
    torch_version=$(python -c "import torch; print(torch.__version__)" 2>/dev/null)
    check_item true "PyTorch: $torch_version"
    ((score++))
else
    check_item false "PyTorch: Not installed"
fi

# CUDA support
((total++))
if python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    cuda_version=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null)
    check_item true "PyTorch CUDA: $cuda_version (GPU acceleration available)"
    ((score++))
else
    check_item false "PyTorch CUDA: Not available"
fi

# Key packages
packages=("numpy" "pandas" "matplotlib" "transformers" "cv2:opencv")
for pkg_info in "${packages[@]}"; do
    ((total++))
    pkg=${pkg_info%%:*}
    name=${pkg_info##*:}
    name=${name:-$pkg}
    
    if python -c "import $pkg" 2>/dev/null; then
        version=$(python -c "import $pkg; print(getattr($pkg, '__version__', 'installed'))" 2>/dev/null || echo "installed")
        check_item true "$name: $version"
        ((score++))
    else
        check_item false "$name: Not installed"
    fi
done

echo
echo "🛠️  Development Tools" 
echo "--------------------"
# Git
((total++))
if command -v git >/dev/null 2>&1; then
    git_version=$(git --version | cut -d' ' -f3)
    check_item true "Git: $git_version"
    ((score++))
else
    check_item false "Git: Not installed"
fi

# VS Code
((total++))
if command -v code >/dev/null 2>&1; then
    check_item true "VS Code: Available"
    ((score++))
else
    check_item false "VS Code: Not available"
fi

# Jupyter
((total++))
if python -c "import jupyter" 2>/dev/null; then
    check_item true "Jupyter: Installed"
    ((score++))
else
    check_item false "Jupyter: Not installed"
fi

# Docker
((total++))
if command -v docker >/dev/null 2>&1; then
    docker_version=$(docker --version | cut -d' ' -f3 | tr -d ',')
    check_item true "Docker: $docker_version"
    ((score++))
else
    check_item false "Docker: Not installed"
fi

echo
echo "📊 Summary"
echo "----------"
percentage=$((score * 100 / total))

if [[ $percentage -ge 80 ]]; then
    echo -e "${GREEN}🎉 Excellent! Your environment is ready for AI/ML development${NC}"
    echo -e "${GREEN}Score: $score/$total ($percentage%)${NC}"
elif [[ $percentage -ge 60 ]]; then
    echo -e "${YELLOW}⚡ Good! Minor improvements recommended${NC}"
    echo -e "${YELLOW}Score: $score/$total ($percentage%)${NC}"
else
    echo -e "${RED}🔧 Needs setup! Run the AI/ML installer${NC}"
    echo -e "${RED}Score: $score/$total ($percentage%)${NC}"
fi

echo
echo "💡 Quick Commands:"
echo "  conda activate aiml          # Activate AI environment"
echo "  jupyter lab --no-browser     # Start Jupyter Lab"
echo "  gpu                          # Monitor GPU usage"
echo "  ~/projects/dotfiles/dev-environment/install-aiml.sh  # Install AI/ML stack"

# Deactivate conda if we activated it
if [[ "$env_active" == "false" ]] && command -v conda >/dev/null 2>&1; then
    conda deactivate 2>/dev/null || true
fi