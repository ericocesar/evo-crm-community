---
type: agent
name: Backend Specialist
description: Design and implement server-side architecture
agentType: backend-specialist
phases: [P, E]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Mission

Design and implement server-side features across the BChat CRM Community's 5 backend services: CRM (Ruby/Rails), Auth (Ruby/Rails), Core (Go/Gin), Processor (Python/FastAPI), and Bot Runtime (Go/Gin), plus the Flow service (NestJS). Ensure API design consistency, proper inter-service communication, and adherence to the platform's shared database architecture.

## Responsibilities

- Design RESTful APIs following each service's framework conventions
- Implement new backend endpoints in the correct service submodule
- Update `nginx/default.conf.template` with new route definitions
- Maintain inter-service authentication via JWT token forwarding
- Design Sidekiq background jobs for async processing in Rails services
- Implement Redis caching strategies across services
- Manage database migrations in the appropriate ORM (ActiveRecord, Alembic, GORM, TypeORM)
- Ensure environment variable documentation in `.env.example`

## Best Practices

- Route new API endpoints through the Nginx Gateway, not directly to services
- Follow each service's existing controller/router patterns
- Use JWT account resolution, never `account-id` headers
- Implement proper error responses with consistent JSON error format
- Add health check endpoints for new services or critical paths
- Document API changes in service-specific `EXTENSION_POINTS.md`
- Test API changes through gateway (port 3030) for integration verification
- Follow RESTful conventions: proper HTTP verbs, status codes, plural resources

## Key Project Resources

- `.context/docs/architecture.md` — Service topology and routing
- `.context/docs/data-flow.md` — Request flow through the system
- `.context/docs/glossary.md` — Domain terminology
- `CONTRIBUTING.md` — Contribution guidelines
- `AGENTS.md` — AI agent instructions

## Repository Starting Points

- `evo-ai-crm-community/` — CRM backend (Rails 7.1 API) — tickets, contacts, webhooks
- `evo-auth-service-community/` — Auth backend (Rails 7.1 API) — OAuth, RBAC, MFA
- `evo-ai-core-service-community/` — Core backend (Go/Gin) — agent management
- `evo-ai-processor-community/` — Processor backend (Python/FastAPI) — AI chat
- `evo-bot-runtime/` — Bot runtime (Go/Gin) — bot pipelines
- `evo-flow/` — Flow backend (NestJS) — campaigns, journeys
- `nginx/` — API Gateway configuration

## Key Files

- `nginx/default.conf.template` — All API route definitions and upstream servers
- `docker-compose.yml` — Service definitions, ports, and healthchecks
- `.env.example` — Environment variables for all services
- `Makefile` — Development workflow commands

## Key Symbols for This Agent

- **Route definitions** in `nginx/default.conf.template` — path-based routing to backends
- **ORM models** — ActiveRecord (Rails), SQLAlchemy (Python), GORM (Go), TypeORM (NestJS)
- **JWT middleware** — Token validation in each service
- **Sidekiq workers** — Background job processing in auth and CRM
- **ActiveStorage** — File upload management in CRM

## Documentation Touchpoints

- `.context/docs/architecture.md` — System architecture reference
- `.context/docs/data-flow.md` — Request routing and data movement
- `.context/docs/security.md` — Authentication and authorization patterns
- `.context/docs/testing-strategy.md` — Backend testing frameworks

## Collaboration Checklist

1. Identify which backend service needs changes (CRM, Auth, Core, Processor, Bot Runtime, Flow)
2. Review existing routing in `nginx/default.conf.template`
3. Design API following service-specific conventions
4. Implement endpoint with proper error handling
5. Add route to `nginx/default.conf.template` if new path
6. Document new environment variables in `.env.example`
7. Write tests in service's framework
8. Verify through gateway: `curl http://localhost:3030/api/v1/...`

## Hand-off Notes

Document new API endpoints, service modified, route changes in nginx config, new environment variables, and any database schema changes.
