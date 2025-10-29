#!/usr/bin/env bash
set -euo pipefail

# Containerized Development Environment Setup
# Adds Docker, K8s tooling, and microservices scaffolding

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🐳 Setting up containerized development environment..."

# Install Docker if not present
install_docker() {
    if command -v docker >/dev/null 2>&1; then
        echo "✅ Docker is already installed"
        docker --version
    else
        echo "📦 Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        echo "✅ Docker installed - restart terminal to use without sudo"
    fi
}

# Install Kubernetes tools
install_k8s_tools() {
    echo "☸️ Installing Kubernetes tools..."
    
    # kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "📦 Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    else
        echo "✅ kubectl already installed: $(kubectl version --client --short 2>/dev/null || echo 'installed')"
    fi
    
    # helm
    if ! command -v helm >/dev/null 2>&1; then
        echo "📦 Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    else
        echo "✅ Helm already installed: $(helm version --short 2>/dev/null || echo 'installed')"
    fi
    
    # k9s (optional but useful)
    if ! command -v k9s >/dev/null 2>&1; then
        echo "📦 Installing k9s..."
        curl -sS https://webinstall.dev/k9s | bash
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "✅ k9s already installed"
    fi
}

# Install development tools
install_dev_tools() {
    echo "🛠️ Installing development tools..."
    
    # Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo "📦 Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "✅ Docker Compose already installed"
    fi
    
    # Skaffold (for K8s development)
    if ! command -v skaffold >/dev/null 2>&1; then
        echo "📦 Installing Skaffold..."
        curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
        chmod +x skaffold
        sudo mv skaffold /usr/local/bin
    else
        echo "✅ Skaffold already installed"
    fi
}

# Create project templates
create_templates() {
    echo "📁 Creating project templates..."
    
    TEMPLATES_DIR="$DOTFILES_ROOT/templates"
    mkdir -p "$TEMPLATES_DIR"
    
    # Microservices template structure
    cat > "$TEMPLATES_DIR/create-microservice-project.sh" << 'EOF'
#!/bin/bash
# Create new microservice project structure

PROJECT_NAME=${1:-my-ai-app}
echo "🚀 Creating microservice project: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"/{ui,api,ml-service,email-parser,infra}

# UI Service (Next.js)
mkdir -p "$PROJECT_NAME/ui"/{src,public,components}

# API Gateway
mkdir -p "$PROJECT_NAME/api"/{routes,middleware,types}

# ML Service
mkdir -p "$PROJECT_NAME/ml-service"/{models,endpoints,utils}

# Email Parser Service  
mkdir -p "$PROJECT_NAME/email-parser"/{parser,processors,schemas}

# Infrastructure
mkdir -p "$PROJECT_NAME/infra"/{docker,k8s,helm}

echo "✅ Project structure created in $PROJECT_NAME/"
echo "📝 Next steps:"
echo "   cd $PROJECT_NAME"
echo "   # Initialize each service..."
EOF
    chmod +x "$TEMPLATES_DIR/create-microservice-project.sh"
    
    # Docker Compose template
    cat > "$TEMPLATES_DIR/docker-compose.template.yml" << 'EOF'
version: '3.8'

services:
  ui:
    build: ./ui
    ports:
      - "3000:3000"
    environment:
      - API_URL=http://api:8000
    depends_on:
      - api
      - redis

  api:
    build: ./api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  email-parser:
    build: ./email-parser
    ports:
      - "8001:8000"
    environment:
      - ML_SERVICE_URL=http://ml-service:8002

  ml-service:
    build: ./ml-service
    ports:
      - "8002:8000"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  postgres:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
EOF

    echo "✅ Templates created in $TEMPLATES_DIR/"
}

# Create development scripts
create_dev_scripts() {
    echo "📝 Creating development scripts..."
    
    # Local development script
    cat > "$DOTFILES_ROOT/dev-local.sh" << 'EOF'
#!/bin/bash
# Local development with dummy services

echo "🚀 Starting local development environment..."

# Start local services
docker-compose -f docker-compose.local.yml up -d postgres redis

# Start Next.js in development mode
cd ui && npm run dev &
UI_PID=$!

# Start API with hot reload
cd ../api && uvicorn main:app --reload --port 8000 &
API_PID=$!

echo "✅ Services started:"
echo "   UI: http://localhost:3000"
echo "   API: http://localhost:8000"
echo "   Docs: http://localhost:8000/docs"

# Cleanup on exit
trap "kill $UI_PID $API_PID; docker-compose down" EXIT
wait
EOF
    chmod +x "$DOTFILES_ROOT/dev-local.sh"
    
    # Production deployment script
    cat > "$DOTFILES_ROOT/deploy-k8s.sh" << 'EOF'
#!/bin/bash
# Deploy to Kubernetes

echo "☸️ Deploying to Kubernetes..."

# Build and push images
skaffold build --push

# Deploy with Helm
helm upgrade --install my-ai-app ./infra/helm/my-ai-app \
  --namespace production \
  --create-namespace

echo "✅ Deployment complete!"
kubectl get pods -n production
EOF
    chmod +x "$DOTFILES_ROOT/deploy-k8s.sh"
}

# Main installation
main() {
    echo "🎯 Setting up containerized development environment..."
    echo
    
    install_docker
    install_k8s_tools
    install_dev_tools
    create_templates
    create_dev_scripts
    
    echo
    echo "🎉 Containerized development setup complete!"
    echo
    echo "🚀 Quick start:"
    echo "   $DOTFILES_ROOT/templates/create-microservice-project.sh my-ai-app"
    echo "   cd my-ai-app"
    echo "   $DOTFILES_ROOT/dev-local.sh    # Local development"
    echo "   $DOTFILES_ROOT/deploy-k8s.sh   # Deploy to K8s"
    echo
    echo "📚 Documentation:"
    echo "   $SCRIPT_DIR/k8s-architecture.md"
}

# Run main function
main "$@"