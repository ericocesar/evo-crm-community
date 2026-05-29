---
type: doc
name: data-flow
description: How data moves through the system and external integrations
category: data-flow
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Data Flow & Integrations

BChat CRM Community processes data through a layered pipeline: client requests enter through the Nginx API Gateway, are authenticated via JWT tokens from the auth service, then routed to domain-specific backend services. All services share a single PostgreSQL database for persistence, with Redis handling caching and background job queues. External integrations (WhatsApp, AI providers) are managed by the processor service.

## Module Dependencies

- **Nginx Gateway** → All backend services (routes requests based on URL path)
- **Frontend (React/Vite)** → Nginx Gateway (all API calls proxied through gateway)
- **Auth Service** → PostgreSQL, Redis (OAuth tokens, user sessions, background jobs)
- **CRM Service** → PostgreSQL, Redis (tickets, contacts, ActionCable, ActiveStorage, Sidekiq)
- **Core Service** → PostgreSQL, Redis (agent configs, MCP servers, tools)
- **Processor Service** → PostgreSQL, Redis, Core Service, Evolution API/Go (chat processing, integrations)
- **Bot Runtime** → Redis, Processor Service (bot pipeline execution)
- **Evo-Flow** → PostgreSQL, Redis, ClickHouse (campaigns, journeys, analytics)

## Service Layer

| Service | Language | Port | Purpose |
|---------|----------|------|---------|
| `evo-auth-service-community` | Ruby/Rails | 3001 | OAuth 2.0 provider, RBAC, MFA, user/account management |
| `evo-ai-crm-community` | Ruby/Rails | 3000 | Tickets, contacts, webhooks, ActionCable, file storage |
| `evo-ai-core-service-community` | Go/Gin | 5555 | Agent CRUD, MCP servers, custom tools, folder management |
| `evo-ai-processor-community` | Python/FastAPI | 8000 | AI chat, A2A protocol, session management, integrations |
| `evo-bot-runtime` | Go/Gin | 8080 | Bot pipeline execution and automation |
| `evo-flow` | NestJS/TS | 3005 | Campaigns, journeys, contact events, analytics |

## High-level Flow

```
User/Browser
    │
    ├─► Frontend SPA (React/Vite) ──► Nginx Gateway (:3030)
    │                                      │
    │         ┌────────────────────────────┤
    │         │         │         │        │
    │         ▼         ▼         ▼        ▼
    │      Auth      CRM      Core    Processor
    │      :3001     :3000    :5555    :8000
    │         │         │         │        │
    │         └─────────┴─────────┴────────┘
    │                      │
    │              ┌───────┴───────┐
    │              │  PostgreSQL   │
    │              │  + pgvector   │
    │              └───────────────┘
    │
    └─► WebSocket (ActionCable) ──► CRM Service (:3000) for real-time updates
```

**Request Lifecycle**:
1. Client sends request to Nginx Gateway (port 3030)
2. Gateway routes based on path prefix (`/api/v1/auth` → auth, `/api/v1/agents` → core, etc.)
3. Gateway adds CORS headers, handles WebSocket upgrade for `/cable`
4. Target service validates JWT token (from Authorization header)
5. Service resolves account context from token (no account-id header needed)
6. Service processes request, reads/writes to PostgreSQL/Redis
7. Response flows back through gateway to client

## Internal Movement

- **HTTP via Gateway**: All inter-service communication uses HTTP through the Nginx gateway with Bearer token forwarding. The `EVOAI_CRM_API_TOKEN` shared secret is used for service-to-service auth.
- **Shared Database**: All services read/write to the same PostgreSQL 16 database. This eliminates distributed transaction complexity but requires coordinated schema changes.
- **Redis**: Used for caching (auth tokens, session data), Sidekiq job queues (auth + CRM), and pub/sub for real-time events.
- **ActionCable WebSocket**: CRM service provides real-time updates to the frontend via WebSocket connections proxied through Nginx at `/cable`.
- **ClickHouse**: evo-flow writes contact events and analytics data to ClickHouse for high-performance querying of campaign/journey data.

## External Integrations

| Integration | Service | Auth Method | Purpose |
|-------------|---------|-------------|---------|
| WhatsApp | evolution-api (Node.js) / evolution-go | WhatsApp Business API / Baileys session | Messaging channel for customer support |
| AI/LLM Providers | evo-ai-processor-community | API keys (configurable via env vars) | AI agent response generation |
| Email (dev) | MailHog | SMTP (no auth, dev only) | Email testing on port 1025 |
| OAuth 2.0 Clients | evo-auth-service-community | Doorkeeper (OAuth 2.0) | Third-party app integration |
| Webhooks | evo-ai-crm-community | Token-based verification | External system notifications |

## Observability & Failure Modes

- **Health Checks**: All services expose health endpoints (`/health`, `/ready`, `/healthz`, `/readyz`). Docker Compose uses these for `depends_on` conditions and container restart policies.
- **Logging**: All services log to stdout/stderr, captured by Docker. Use `make logs SERVICE=name` for filtered viewing.
- **Sidekiq Dashboard**: Available in CRM and Auth services for monitoring background job queues.
- **Retry Strategies**: Sidekiq provides built-in retry with exponential backoff for failed jobs. HTTP clients in services should implement timeout and retry configurations.
- **Circuit Breaking**: Not implemented at the infrastructure level. The Nginx gateway will return 502 if upstreams are unavailable.
- **Data Recovery**: PostgreSQL data persists via named Docker volumes (`postgres_data`). Regular backups recommended for production.
