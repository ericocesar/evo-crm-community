---
type: doc
name: architecture
description: System architecture, layers, patterns, and design decisions
category: architecture
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Architecture Notes

Evo CRM Community follows a **microservices orchestration pattern** where 6 backend services communicate through a centralized Nginx API Gateway. The system is designed for single-tenant deployments with all services sharing one PostgreSQL database. Inter-service authentication uses JWT tokens from the auth service, forwarded through the gateway. Each service is independently containerized and versioned, with the umbrella repository pinning submodules at specific release tags.

## System Architecture Overview

The platform uses an **API Gateway pattern** with Nginx as the single entry point on port 3030. All client requests (browser, API clients, webhooks) hit the Nginx gateway, which routes based on URL path prefixes to the appropriate backend service. Services communicate with each other via HTTP through the gateway using Bearer token authentication and a shared `EVOAI_CRM_API_TOKEN` secret.

```
Client (Browser/API)
       │
       ▼
┌─────────────────┐
│  Nginx Gateway  │  Port 3030
│  (envsubst)     │
└───┬───┬───┬───┬─┘
    │   │   │   │
    ▼   ▼   ▼   ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│ Auth │ │ CRM  │ │ Core │ │ Proc │ │ Bot  │ │ Flow │
│:3001 │ │:3000 │ │:5555 │ │:8000 │ │:8080 │ │:3005 │
└──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘
   │        │        │        │        │        │
   └────────┴────────┴────────┴────────┴────────┘
                       │
              ┌────────┴────────┐
              │   PostgreSQL 16 │  Shared DB
              │   + pgvector    │
              └─────────────────┘
```

## Architectural Layers

- **Gateway Layer** (`nginx/default.conf.template`): Path-based routing, CORS headers, WebSocket upgrade, file upload size limits, environment variable substitution via envsubst
- **Authentication Layer** (`evo-auth-service-community/`): OAuth 2.0 provider (Doorkeeper), RBAC with roles/permissions, MFA, account management, user profiles
- **CRM Layer** (`evo-ai-crm-community/`): Ticket management, contact management, webhooks, ActionCable real-time updates, ActiveStorage file handling, Sidekiq background jobs
- **AI Agent Layer** (`evo-ai-core-service-community/`): Agent CRUD, MCP server configuration, custom tools, folder organization
- **AI Processing Layer** (`evo-ai-processor-community/`): Chat sessions, A2A protocol (agent-to-agent), conversation processing, third-party integrations (WhatsApp via evolution-api/evolution-go)
- **Bot Automation Layer** (`evo-bot-runtime/`): Bot pipeline execution, automation workflows
- **Campaign Layer** (`evo-flow/`): Campaign management, customer journeys, contact events, ClickHouse analytics
- **Presentation Layer** (`evo-ai-frontend-community/`): React SPA served via Nginx in production
- **Data Layer**: PostgreSQL 16 (shared, pgvector), Redis (caching/queues), ClickHouse (analytics)

> Use `context({ action: "getMap", section: "all" })` for generated architecture and dependency summaries.

## Detected Design Patterns

| Pattern | Confidence | Locations | Description |
|---------|------------|-----------|-------------|
| API Gateway | 100% | `nginx/default.conf.template` | Single entry point routing to all backend services |
| Service per Domain | 100% | All submodule directories | Each business domain (auth, crm, agents, processing, bots, campaigns) is a separate service |
| Shared Database | 100% | `docker-compose.yml` | All services share one PostgreSQL instance (single-tenant design) |
| Token-Based Auth | 100% | Gateway config, all services | JWT from auth service forwarded to all backend services |
| Background Job Queue | 100% | `docker-compose.yml` (sidekiq containers) | Sidekiq + Redis for async processing in auth and CRM |
| Webhook Receiver | 100% | `nginx/default.conf.template`, CRM routes | Dedicated webhook endpoints routed to CRM and processor |
| Extensibility Points | 100% | `EXTENSION_POINTS.md` in each submodule | Open-core customization via defined extension points |
| Frontend Plugin Runtime | 100% | evo-ai-frontend-community | Plugin host runtime for frontend customization |

## Entry Points

- **API Gateway**: `nginx/default.conf.template:1` — Routes all traffic, defines upstream servers, handles CORS and WebSocket upgrade
- **Docker Compose**: `docker-compose.yml:1` — Defines all 9 services, networks, volumes, healthchecks
- **Makefile**: `Makefile:1` — 20+ developer workflow targets
- **Setup Script**: `setup.sh:1` — Interactive first-time bootstrap
- **Environment Config**: `.env.example:1` — All environment variables across services

## Public API

| Symbol | Type | Location |
|--------|------|----------|
| `/api/v1/auth/*` | Auth endpoints | Routed to evo-auth-service-community:3001 |
| `/oauth/*` | OAuth 2.0 provider | Routed to evo-auth-service-community:3001 |
| `/api/v1/profile/*`, `/api/v1/users/*` | User management | Routed to evo-auth-service-community:3001 |
| `/api/v1/accounts/*` | Account management | Routed to evo-auth-service-community:3001 |
| `/api/v1/agents/*` | Agent CRUD | Routed to evo-ai-core-service-community:5555 |
| `/api/v1/mcp-servers/*` | MCP server config | Routed to evo-ai-core-service-community:5555 |
| `/api/v1/chat/*` | AI chat sessions | Routed to evo-ai-processor-community:8000 |
| `/api/v1/a2a/*` | Agent-to-agent protocol | Routed to evo-ai-processor-community:8000 |
| `/api/v1/bot-runtime/*` | Bot pipelines | Routed to evo-bot-runtime:8080 |
| `/webhooks/*` | Webhook receivers | Routed to evo-ai-crm-community:3000 |
| `/cable` | ActionCable WebSocket | Routed to evo-ai-crm-community:3000 |
| `/rails/active_storage/*` | File uploads/downloads | Routed to evo-ai-crm-community:3000 |
| `/setup/*` | Setup wizard | Routed to evo-auth-service-community:3001 |
| `/api/v1/super_admin/*` | Super admin operations | Split between CRM and Auth services |

## Internal System Boundaries

- **Auth ↔ CRM**: Auth service manages users/roles/permissions; CRM consumes JWT tokens to resolve account context. Both share the same PostgreSQL schema (CRM schema must be loaded first).
- **CRM ↔ Core**: CRM creates/manages agents; Core handles agent configuration, MCP servers, and tools. Communication via HTTP through gateway with token forwarding.
- **Core ↔ Processor**: Core provides agent definitions; Processor executes AI chat sessions and A2A interactions using those agent configs.
- **Processor ↔ Evolution API/Go**: Processor integrates with WhatsApp via evolution-api (Node.js) or evolution-go messenger providers.
- **Flow ↔ All Services**: evo-flow consumes events from other services for campaign and journey analytics, storing data in ClickHouse.
- **Data Ownership**: All services write to the shared PostgreSQL database. No service owns exclusive tables — the schema is designed for cohabitation in single-tenant mode.

## External Service Dependencies

- **WhatsApp** (via evolution-api / evolution-go): Messaging provider integration using WhatsApp Business API or Baileys
- **OpenAI / AI Providers**: The processor service integrates with external LLM APIs for AI agent responses (configurable via environment)
- **MailHog** (dev only): SMTP testing on port 1025, web UI on port 8025
- **pgvector**: PostgreSQL extension for vector similarity search in AI embeddings
- **GitHub Container Registry (GHCR)**: Docker image hosting for release builds
- **Docker Hub** (`evoapicloud/*`): Public Docker image distribution

## Key Decisions & Trade-offs

1. **Single-Tenant by Design**: The community edition is deliberately single-tenant — one account per installation. This simplifies the data model (no tenant isolation logic) and removes billing/plans complexity. Multi-tenancy is available in the enterprise edition.
2. **Shared PostgreSQL Database**: All services share one database rather than having separate DBs per service. This simplifies deployment and avoids distributed transaction complexity, at the cost of tighter coupling between service schemas.
3. **Nginx Gateway over Service Mesh**: Chose Nginx with envsubst for simplicity. No service mesh (Istio/Linkerd) needed for a single-tenant deployment. Traefik is available for Docker Swarm production deployments.
4. **Git Submodules over Monorepo Tooling**: Services are Git submodules rather than a monorepo with shared tooling. Each service has independent build, test, and release pipelines while being pinned at known-good versions in the umbrella repo.
5. **JWT Token Forwarding**: Inter-service auth uses forwarded JWT tokens rather than mTLS or API keys. The token from the auth service carries account context, eliminating the need for account-id headers between services.
6. **CRM Seeded Before Auth**: The CRM schema must be loaded before auth seeds because the shared database schema is defined by CRM migrations. Auth tables live alongside CRM tables in the same database.

## Risks & Constraints

- **PostgreSQL as Single Point of Failure**: All services depend on one database instance. For production, consider read replicas and automated backups.
- **Submodule Drift**: Submodules can fall out of sync if developers forget to update them after pulling the umbrella repo. The setup script and Makefile mitigate this but don't enforce it programmatically.
- **No Service-Level Tests at Umbrella Level**: CI validates Docker Compose and lints Dockerfiles but does not run service-level tests. Each submodule must maintain its own test suite independently.
- **Port Conflicts**: Nine services with hardcoded ports (3000, 3001, 3005, 3030, 5173, 5432, 5555, 6379, 8000, 8025, 8080, 8123, 9000) can conflict with other local services.
- **Single-Tenant Limitation**: Organizations needing multi-tenancy must migrate to the enterprise edition, which has a different architecture.

## Top Directories Snapshot

- `.github/` — CI/CD workflows and PR/issue templates
- `.context/` — AI agent documentation, playbooks, and harness
- `docs/` — User-facing documentation
- `nginx/` — API gateway Dockerfile and routing config
- `scripts/` — Build and deployment shell scripts
- `public/` — Static assets
- `evo-ai-crm-community/` — [submodule] CRM service (Ruby/Rails)
- `evo-auth-service-community/` — [submodule] Auth service (Ruby/Rails)
- `evo-ai-core-service-community/` — [submodule] Core service (Go/Gin)
- `evo-ai-processor-community/` — [submodule] Processor service (Python/FastAPI)
- `evo-ai-frontend-community/` — [submodule] Frontend (React/Vite)
- `evo-bot-runtime/` — [submodule] Bot runtime (Go/Gin)
- `evo-flow/` — [submodule] Flow service (NestJS)
- `evo-nexus/` — [submodule] Multi-agent layer
- `evolution-api/` — [submodule] WhatsApp provider (Node.js)
- `evolution-go/` — [submodule] WhatsApp provider (Go)

## Related Resources

- `project-overview.md` — High-level project description and quick facts
- `data-flow.md` — Request flow through the system
- `development-workflow.md` — Engineering processes and conventions
- `nginx/default.conf.template` — Complete routing configuration
- `docker-compose.yml` — Service definitions and dependencies
- `.env.example` — Environment variable reference
