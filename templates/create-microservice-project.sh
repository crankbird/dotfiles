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
