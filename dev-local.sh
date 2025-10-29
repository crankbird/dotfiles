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
