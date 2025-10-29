# Graphite Pull-Based Workflow Guide

Graphite enables disciplined, pull-based development with **stacked diffs** - perfect for AI/ML projects where features are built incrementally.

## Why Graphite for AI/ML?

- **🔬 Experimental Nature**: AI/ML development is iterative - stacked PRs let you build experiments step-by-step
- **📊 Model Iterations**: Each model improvement can be its own reviewable PR in a stack
- **🧪 A/B Testing**: Compare different approaches in parallel stacks
- **👥 Team Collaboration**: Easier code review with smaller, focused changes
- **🚀 Faster Iteration**: Land changes incrementally instead of waiting for large PRs

## Setup & Authentication

```bash
# Install (done by installer script)
npm install -g @withgraphite/graphite-cli

# Authenticate with GitHub
gh auth login
gt auth --token $(gh auth token)

# Initialize in a repository
cd your-ai-project
gt repo init
```

## Core Graphite Workflow

### 1. **Start with Trunk**
```bash
# Always start from main
git checkout main
git pull origin main
gtsync  # alias for gt repo sync
```

### 2. **Create Feature Branches**
```bash
# Create a new branch for your feature
gtcreate feature/data-preprocessing  # alias for gt branch create

# Make your changes
git add .
git commit -m "Add data preprocessing pipeline"
```

### 3. **Stack Multiple Changes**
```bash
# Create another branch stacked on top
gtcreate feature/model-training

# Make more changes
git add .
git commit -m "Add BERT fine-tuning script"

# Add another layer
gtcreate feature/evaluation-metrics

# More changes
git add .
git commit -m "Add evaluation metrics and visualization"
```

### 4. **Submit Stacked PRs**
```bash
# Submit entire stack for review
gtsubmit  # alias for gt stack submit

# Or submit individual branches
gt branch submit feature/data-preprocessing
```

### 5. **Manage the Stack**
```bash
# View your stack
gtstack  # alias for gt stack
gtlog    # alias for gt log (visual representation)

# Sync with remote changes
gtsync   # alias for gt repo sync

# Clean up merged branches
gtclean  # alias for gt branch delete
```

## AI/ML Specific Workflows

### **Experiment Workflow**
```bash
# Base experiment setup
gtcreate experiment/baseline-model
# Add: data loading, basic model, training loop
git add . && git commit -m "Add baseline BERT model"

# Hyperparameter tuning (stacked on baseline)
gtcreate experiment/hyperparameter-tuning  
# Add: learning rate scheduling, batch size optimization
git add . && git commit -m "Add hyperparameter optimization"

# Advanced features (stacked on tuning)
gtcreate experiment/advanced-features
# Add: attention visualization, layer freezing
git add . && git commit -m "Add advanced training features"

# Submit all for review
gtsubmit
```

### **Model Comparison Workflow**
```bash
# Create parallel stacks for different models
gtcreate model/bert-base
git add . && git commit -m "Implement BERT base model"

# Go back to main and create competing approach
git checkout main
gtcreate model/distilbert
git add . && git commit -m "Implement DistilBERT model"

# Submit both approaches
gt branch submit model/bert-base
gt branch submit model/distilbert
```

### **Data Pipeline Workflow**
```bash
# Data cleaning
gtcreate data/cleaning
git add . && git commit -m "Add data cleaning and validation"

# Feature engineering (depends on cleaning)
gtcreate data/feature-engineering
git add . && git commit -m "Add feature extraction and encoding"

# Data augmentation (depends on features)
gtcreate data/augmentation
git add . && git commit -m "Add data augmentation strategies"

gtsubmit  # Submit entire data pipeline stack
```

## Branch Protection & Repository Setup

```bash
# Set up branch protection (run once per repo)
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["continuous-integration"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

## Graphite Configuration

Create `.graphite_repo_config` in your repo root:

```json
{
  "trunk": "main",
  "ignorePatterns": [
    "*.pth",
    "*.pt",
    "*.safetensors",
    "/models/downloaded/",
    "/data/raw/",
    "/outputs/",
    "/logs/",
    "wandb/",
    ".neptune/"
  ]
}
```

## Advanced Commands

```bash
# Restack after main branch updates
gt stack restack

# Fix conflicts in stack
gt stack fix

# Move branches in stack
gt branch up    # Move current branch up in stack
gt branch down  # Move current branch down in stack

# Create branch at specific position
gt branch create --insert-after feature/data-preprocessing feature/new-feature

# View stack status
gt stack status

# Validate stack integrity
gt stack validate
```

## Integration with AI/ML Tools

### **With Jupyter Notebooks**
```bash
# Create notebook-specific branches
gtcreate notebooks/data-exploration
# Add your .ipynb files
git add experiments.ipynb
git commit -m "Add data exploration notebook"

# Stack analysis notebooks
gtcreate notebooks/model-analysis
git add analysis.ipynb  
git commit -m "Add model performance analysis"
```

### **With Weights & Biases**
```bash
# Each experiment gets its own branch
gtcreate experiments/wandb-integration
# Add W&B logging
git add . && git commit -m "Add W&B experiment tracking"

# Stack visualization improvements
gtcreate experiments/wandb-visualizations
git add . && git commit -m "Add custom W&B charts and reports"
```

### **With Model Checkpoints**
```bash
# Use Git LFS for large files (set up once)
git lfs track "*.pth" "*.pt" "*.safetensors"
git add .gitattributes

# Each model version in its own branch
gtcreate models/v1.0
git add model_v1.pth
git commit -m "Add trained model v1.0 checkpoint"
```

## Daily Workflow Commands

```bash
# Morning sync
gtsync

# Start new feature
gtcreate feature/my-new-feature

# Work and commit
git add . && git commit -m "Implementation details"

# Add to stack or submit
gtsubmit

# Review stack
gtlog

# Clean up merged branches
gtclean

# Evening sync
gtsync
```

## Benefits for AI/ML Teams

1. **🔬 Reviewable Experiments**: Each experiment step is a separate, focused PR
2. **📊 Gradual Model Improvement**: Stack improvements on top of baseline models
3. **🤝 Parallel Development**: Multiple team members can work on different parts of the stack
4. **📈 Clear Progress**: Visual representation of feature development progress
5. **🚀 Faster Integration**: Merge small changes quickly instead of waiting for large features
6. **🔄 Easy Rollback**: Revert specific changes without affecting the entire feature

This workflow enforces discipline while maintaining the flexibility needed for AI/ML experimentation!