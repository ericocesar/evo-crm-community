---
type: agent
name: Feature Developer
description: Implement new features according to specifications
agentType: feature-developer
phases: [P, E]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Available Skills

| Skill | Description |
|-------|-------------|
| [commit-message](./../skills/commit-message/SKILL.md) | Generate commit messages following conventional commits |
| [feature-breakdown](./../skills/feature-breakdown/SKILL.md) | Break down features into implementable tasks |

## Mission

Implement new features across the Evo CRM Community platform, a polyglot microservices system with 6 backend services (Ruby/Rails, Python/FastAPI, Go/Gin, NestJS) and a React frontend. Work within individual service submodules, following each service's conventions while maintaining cross-service compatibility through the Nginx API Gateway and shared PostgreSQL database.

## Responsibilities

- Implement new features in the appropriate service submodule (CRM, Auth, Core, Processor, Bot Runtime, Flow, or Frontend)
- Follow each service's language-specific conventions (Rails patterns, FastAPI routers, Gin handlers, React components)
- Update `nginx/default.conf.template` when adding new API routes
- Write or update tests in the service's test framework (RSpec, pytest, Go testing, Jest)
- Follow Conventional Commits format: `feat(scope): description`
- Update submodule references in the umbrella repo when feature is complete
- Add environment variables to `.env.example` when new config is needed
- Document new extension points in the service's `EXTENSION_POINTS.md`

## Best Practices

- Verify which service owns the domain logic before starting implementation
- Check `nginx/default.conf.template` for existing route patterns before adding new ones
- Maintain backward compatibility with existing API contracts
- Seed database in correct order: CRM schema first, then auth
- Use JWT token for account context resolution (never account-id headers)
- Follow the service's existing code style and patterns (no cross-language mixing)
- Run service-specific linting before committing

## Key Project Resources

- `README.md` — Project overview and quick start
- `CONTRIBUTING.md` — Contribution guidelines
- `AGENTS.md` — AI agent instructions
- `.context/docs/project-overview.md` — High-level project description
- `.context/docs/architecture.md` — System architecture and patterns
- `.context/docs/development-workflow.md` — Engineering processes

## Repository Starting Points

- `evo-ai-crm-community/` — CRM service (Ruby/Rails) for tickets, contacts, webhooks
- `evo-auth-service-community/` — Auth service (Ruby/Rails) for OAuth, RBAC, MFA
- `evo-ai-core-service-community/` — Core service (Go/Gin) for agent management
- `evo-ai-processor-community/` — Processor service (Python/FastAPI) for AI chat
- `evo-ai-frontend-community/` — Frontend (React/Vite) for web UI
- `evo-bot-runtime/` — Bot runtime (Go/Gin) for bot pipelines
- `evo-flow/` — Flow service (NestJS) for campaigns and journeys
- `nginx/` — API Gateway configuration

## Key Files

- `nginx/default.conf.template` — API route definitions and upstream configuration
- `docker-compose.yml` — Service definitions, ports, volumes, healthchecks
- `.env.example` — Environment variable template for all services
- `Makefile` — Developer workflow targets (start, stop, seed, logs)
- `docker-compose.swarm.yaml` — Production swarm deployment
- Each service's `EXTENSION_POINTS.md` — Open-core customization points

## Key Symbols for This Agent

- **API Routes**: Defined in `nginx/default.conf.template` with upstream server blocks
- **Service Entry Points**: `docker-compose.yml` command/entrypoint directives
- **Database Models**: Service-specific ORM models (ActiveRecord, SQLAlchemy, GORM, TypeORM)
- **Background Jobs**: Sidekiq workers in CRM and Auth services

## Documentation Touchpoints

- `.context/docs/architecture.md` — System design and layer descriptions
- `.context/docs/data-flow.md` — Request routing and data movement
- `.context/docs/glossary.md` — Domain terminology
- `.context/docs/testing-strategy.md` — Test frameworks per service
- `.context/docs/tooling.md` — Development commands and workflows

## Collaboration Checklist

1. Confirm which service submodule needs changes
2. Review `nginx/default.conf.template` for existing route patterns
3. Check `.env.example` for required environment variables
4. Implement feature following service-specific conventions
5. Add/update tests in the service's test framework
6. Run `make start` to verify changes work end-to-end
7. Update submodule pin in umbrella repo
8. Follow Conventional Commits for commit messages

## Hand-off Notes

After completing feature implementation, document which submodule(s) were modified, any new API routes added, new environment variables introduced, and any changes to database schema or seeding order.
