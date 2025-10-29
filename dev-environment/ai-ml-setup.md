# Development Environment Assessment & Setup Guide

## Current Environment Status ✅❌

### ✅ **Excellent Foundation**
- **OS**: Ubuntu 24.04.3 LTS (WSL2) - Latest LTS, excellent for AI/ML
- **GPU**: NVIDIA RTX 4070 Mobile (8GB VRAM) - Perfect for lightweight AI/ML
- **CUDA**: Driver 581.57, CUDA 13.0, Toolkit 12.6 - Fully functional
- **Memory**: 16GB RAM + 4GB swap - Good for most AI workloads
- **Storage**: 1TB with 934GB free - Plenty of space for datasets/models
- **CPU**: Intel i7-13620H (16 threads) - Strong for preprocessing
- **Tools**: Git, VS Code, Docker, curl, wget - Core dev tools present

### ❌ **Missing Critical Components**
- **Python Package Manager**: uv (fast Rust-based package manager)
- **Python AI/ML Stack**: PyTorch, TensorFlow, NumPy, etc.
- **Environment Management**: Conda/Mamba (recommended over venv for AI/ML)
- **Node.js**: Useful for AI tooling, web interfaces, deployment
- **Jupyter**: Essential for AI/ML experimentation
- **Key Libraries**: Transformers, Diffusers, OpenCV, etc.

## Recommended Setup for Lightweight AI/ML

### 1. **Install UV** (Fast Python Package Manager)
```bash
# Install uv (much faster than pip)
curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Test installation
uv --version
```

### 2. **Install Miniconda** (Better than pip for AI/ML)
```bash
# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Update conda
conda update conda
conda config --set auto_activate_base false
```

### 3. **Create AI/ML Environment** (Conda + UV hybrid approach)
```bash
# Create a dedicated environment for AI/ML work
conda create -n aiml python=3.11 -y
conda activate aiml

# Core scientific computing (conda for complex dependencies)
conda install numpy scipy pandas matplotlib seaborn jupyter ipykernel -c conda-forge -y

# PyTorch with CUDA support (conda for GPU compatibility)
conda install pytorch pytorch-cuda=12.1 torchvision torchaudio -c pytorch -c nvidia -y

# Pure Python packages (uv for speed)
uv pip install transformers datasets accelerate diffusers tokenizers

# Computer Vision (conda for system dependencies)
conda install opencv pillow scikit-image -c conda-forge -y

# Additional ML libraries (uv for pure Python packages)
uv pip install scikit-learn xgboost lightgbm optuna wandb

# Development tools (uv is much faster)
uv pip install black isort flake8 pytest ipywidgets tqdm rich
```

### 3. **Install Node.js** (for AI tooling)
```bash
# Install Node.js via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Useful AI/ML Node packages
npm install -g @tensorflow/tfjs-node yaml-cli http-server
```

### 4. **Specialized AI Tools** (All with UV for speed)
```bash
# Activate AI environment
conda activate aiml

# For LLM work (uv is much faster for these)
uv pip install openai anthropic ollama litellm

# For computer vision
uv pip install ultralytics roboflow supervision

# For audio processing  
uv pip install librosa soundfile whisper-openai

# For model optimization
uv pip install optimum onnx onnxruntime-gpu

# For experiment tracking
uv pip install mlflow tensorboard
```

## Why UV + Conda?

**Conda**: Best for system-level dependencies, Python versions, and packages with C extensions (PyTorch, NumPy, OpenCV)  
**UV**: 10-100x faster than pip for pure Python packages, better dependency resolution

This hybrid approach gives you the best of both worlds!

## RTX 4070 Mobile Optimization

### **Memory Management** (8GB VRAM)
```python
# Recommended settings for 8GB VRAM
import torch

# Enable memory efficient attention
torch.backends.cuda.enable_flash_sdp(True)

# Set memory fraction
torch.cuda.set_per_process_memory_fraction(0.8)  # Use 80% of VRAM

# Enable gradient checkpointing for training
# model.gradient_checkpointing_enable()
```

### **Model Size Guidelines**
- **Language Models**: Up to 7B parameters (4-bit quantization)
- **Image Models**: Stable Diffusion 1.5/2.1, SDXL (with optimizations)
- **Vision Models**: YOLOv8/9, EfficientNet, ResNet variants
- **Audio Models**: Whisper base/small, TTS models

### **Batch Size Recommendations**
- **Text Generation**: 1-4 sequences
- **Image Generation**: 1-2 images at 512x512, 1 at 1024x1024
- **Image Classification**: 16-64 samples
- **Object Detection**: 4-8 images

## Project Structure Template

```bash
# Create standardized AI project structure
mkdir -p ~/ai-projects/template/{data,models,notebooks,src,configs,outputs,logs}
cd ~/ai-projects/template

# Create template files
cat > environment.yml << 'EOF'
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

cat > .gitignore << 'EOF'
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
```

## VS Code Extensions for AI/ML

```bash
# Install essential extensions
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension ms-python.black-formatter
code --install-extension ms-python.isort
code --install-extension ms-python.flake8
code --install-extension GitHub.copilot
code --install-extension tamasfe.even-better-toml
```

## Performance Monitoring

### **GPU Monitoring**
```bash
# Add to ~/.bashrc for easy GPU monitoring
alias gpu='watch -n 1 nvidia-smi'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv'
alias gputemp='nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader'
```

### **System Monitoring**
```bash
# Install system monitoring tools
sudo apt update
sudo apt install htop iotop ncdu tree

# Python memory profiling
pip install memory-profiler py-spy
```

## Docker Setup for AI/ML

```bash
# Add Docker GPU support
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt update
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker

# Test GPU in Docker
docker run --rm --gpus all nvidia/cuda:12.1-base-ubuntu22.04 nvidia-smi
```

## Quick Start Commands

```bash
# Daily workflow
conda activate aiml
cd ~/ai-projects/current-project
jupyter lab --no-browser --port=8888

# Monitor resources while training
gpu  # Watch GPU usage
htop # Watch CPU/RAM usage

# Test CUDA setup
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}, Device: {torch.cuda.get_device_name()}')"
```

## Recommended First Projects

1. **Text Classification** with DistilBERT (fits in 8GB easily)
2. **Image Classification** with EfficientNet or ResNet
3. **Stable Diffusion** image generation (with memory optimizations)
4. **Object Detection** with YOLOv8
5. **Speech Recognition** with Whisper
6. **Fine-tuning** smaller language models (Phi-3, CodeLlama 7B)

## Security & Best Practices

```bash
# Set up secure environment variables
touch ~/.env
echo 'OPENAI_API_KEY=your_key_here' >> ~/.env
echo 'HUGGINGFACE_HUB_TOKEN=your_token_here' >> ~/.env

# Add to ~/.bashrc
echo 'set -a; source ~/.env; set +a' >> ~/.bashrc
```

This setup gives you a production-ready AI/ML environment optimized for your RTX 4070 Mobile with excellent tooling for lightweight but powerful AI development.