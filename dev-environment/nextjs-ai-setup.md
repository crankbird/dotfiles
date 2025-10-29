# Frontend Development Setup (Next.js + AI)

## Quick Next.js + AI Project Setup

```bash
# Create new AI-powered Next.js project
npx create-next-app@latest my-ai-app --typescript --tailwind --eslint --app
cd my-ai-app

# Add AI dependencies
npm install ai @ai-sdk/openai @ai-sdk/anthropic
npm install @vercel/analytics @vercel/speed-insights

# Development
npm run dev
```

## Essential AI Packages for Next.js

- `ai` - Vercel AI SDK for streaming responses
- `@ai-sdk/openai` - OpenAI integration
- `@ai-sdk/anthropic` - Anthropic/Claude integration
- `langchain` - For complex AI workflows
- `@pinecone-database/pinecone` - Vector database
- `@supabase/supabase-js` - Database with vector support

## Project Templates

### 1. AI Chat Interface
```bash
npx create-next-app@latest ai-chat --example https://github.com/vercel/ai/tree/main/examples/next-openai
```

### 2. AI-Powered Content Generator
```bash
npx create-next-app@latest ai-content --example https://github.com/vercel/ai/tree/main/examples/next-anthropic
```

### 3. RAG (Retrieval Augmented Generation) App
```bash
npx create-next-app@latest rag-app --example https://github.com/vercel/ai/tree/main/examples/next-langchain
```

## Development Workflow

1. **Backend AI** (Python/WSL) → Process data, train models, serve APIs
2. **Frontend** (Next.js) → User interface, real-time AI interactions
3. **Deployment** → Vercel for frontend, your choice for backend

## Recommended Setup

- Keep heavy AI/ML work in Python (this WSL environment)
- Use Next.js for rapid UI prototyping and user-facing AI features
- Connect them via APIs or direct database access