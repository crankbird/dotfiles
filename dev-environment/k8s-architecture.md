# Containerized AI/ML Architecture Setup

## Service Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Next.js UI    │───▶│   API Gateway    │───▶│  Email Parser   │
│   (Frontend)    │    │   (Next.js API)  │    │   (Python)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       ▼
         │              ┌──────────────────┐    ┌─────────────────┐
         │              │   Auth Service   │    │   ML Models     │
         │              │   (Next.js)      │    │   (Python)      │
         │              └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Shared Data Layer                          │
│            (PostgreSQL + Redis + Vector DB)                    │
└─────────────────────────────────────────────────────────────────┘
```

## Container Strategy

### 1. UI Service (Next.js)
- **Purpose**: Frontend + API Gateway
- **Technology**: Next.js 14+ with App Router
- **Responsibilities**: UI, routing, authentication, API orchestration

### 2. Email Parser Service
- **Purpose**: Email processing and parsing
- **Technology**: FastAPI + Python
- **Responsibilities**: Email ingestion, parsing, metadata extraction

### 3. ML Service
- **Purpose**: AI/ML processing
- **Technology**: FastAPI + PyTorch
- **Responsibilities**: Classification, embedding generation, inference

### 4. Data Services
- **Purpose**: Persistence and caching
- **Technology**: PostgreSQL + Redis + Qdrant/Pinecone
- **Responsibilities**: Data storage, session management, vector search

## IPC Design Patterns

### Option 1: HTTP APIs (Recommended for Start)
```typescript
// Dummy shim for development
class EmailParserClient {
  async parseEmail(content: string) {
    if (process.env.NODE_ENV === 'development') {
      // Dummy response for local development
      return { sender: 'test@example.com', subject: 'Test' };
    }
    // Real HTTP call to parser service
    return fetch('/api/parse-email', { method: 'POST', body: content });
  }
}
```

### Option 2: Message Queue (Production)
```typescript
// Event-driven with Redis/RabbitMQ
class EmailParserQueue {
  async submitEmail(email: string): Promise<string> {
    const jobId = uuid();
    await redis.lpush('email_queue', JSON.stringify({ id: jobId, email }));
    return jobId;
  }
  
  async getResult(jobId: string) {
    return redis.get(`result:${jobId}`);
  }
}
```

## Development Workflow

1. **Local Development**: Dummy shims, SQLite, no containers
2. **Integration Testing**: Docker Compose with real services
3. **Production**: Kubernetes with proper service mesh