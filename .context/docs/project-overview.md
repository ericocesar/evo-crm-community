---
type: doc
name: project-overview
description: High-level overview of the project, its purpose, and key components
category: overview
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Project Overview

Evo CRM Community is an open-source, single-tenant AI-powered customer support platform built by the Evolution Foundation. It provides a complete suite for AI-assisted customer support — authentication/authorization (OAuth 2.0 + RBAC), CRM with ticket/contact management, AI agent creation and management, agent execution pipelines, bot runtime automation, and a modern React frontend. The platform enables organizations to deploy their own AI customer service infrastructure without vendor lock-in or multi-tenancy overhead.

## Codebase Reference

> **Semantic Snapshot**: Use `context({ action: "getMap", section: "all" })` for generated stack, architecture layers, key files, and dependency hotspots.

## Quick Facts

- **Root**: `/Users/ericocesar/Mac.local/boltdev/2026/BChat/evo-crm-community`
- **Languages**: Ruby (Rails), TypeScript (React, NestJS), Python (FastAPI), Go (Gin)
- **Entry**: `docker-compose.yml` orchestrates all services; `nginx/default.conf.template` is the API gateway
- **Version**: v1.0.0-rc3
- **License**: Apache 2.0 with additional brand-protection conditions
- **Organization**: Evolution Foundation (https://evolutionfoundation.com.br)

## Entry Points

- **API Gateway**: `nginx/default.conf.template:1` — Nginx reverse proxy on port 3030 routing to all backend services
- **Makefile**: `Makefile:1` — 20+ targets for setup, build, seed, and shell access
- **Setup Script**: `setup.sh:1` — Interactive first-time bootstrap script
- **CRM Service**: `evo-ai-crm-community/` (submodule) — Rails 7.1 API on port 3000
- **Auth Service**: `evo-auth-service-community/` (submodule) — Rails 7.1 API on port 3001
- **Core Service**: `evo-ai-core-service-community/` (submodule) — Go/Gin on port 5555
- **Processor Service**: `evo-ai-processor-community/` (submodule) — Python/FastAPI on port 8000
- **Bot Runtime**: `evo-bot-runtime/` (submodule) — Go/Gin on port 8080
- **Evo-Flow**: `evo-flow/` (submodule) — NestJS on port 3005
- **Frontend**: `evo-ai-frontend-community/` (submodule) — React/Vite on port 5173

## Key Exports

- **API Routes** are defined in `nginx/default.conf.template` and route to 6 backend services
- **Auth**: OAuth 2.0 provider via Doorkeeper, RBAC with roles/permissions, MFA, account management
- **CRM**: Tickets, contacts, webhooks, ActionCable WebSocket, ActiveStorage file uploads
- **Core**: Agent management, MCP servers, custom tools, folder organization
- **Processor**: AI chat sessions, A2A protocol, integrations (WhatsApp, etc.)
- **Bot Runtime**: Bot pipeline execution and automation
- **Evo-Flow**: Campaigns, journeys, contact events with ClickHouse analytics
- **Docker Images** published at `evoapicloud/*` (Docker Hub) and `ghcr.io/evolution-foundation/*` (GHCR)

## File Structure & Code Organization

- `.github/` — CI/CD workflows (`ci.yml`, `release.yml`, `gateway-publish.yml`), issue/PR templates
- `.context/` — AI agent context: documentation, agent playbooks, skills, harness
- `docs/` — User-facing documentation (setup guides, troubleshooting, journeys)
- `nginx/` — API gateway Dockerfile and 500-line routing configuration template
- `scripts/` — Build & deploy shell scripts (`build-push.sh`, `buildfront.sh`, `deploy.sh`)
- `public/` — Static assets (logo)
- `evo-ai-crm-community/` — [submodule] Ruby/Rails CRM core service
- `evo-auth-service-community/` — [submodule] Ruby/Rails authentication service
- `evo-ai-core-service-community/` — [submodule] Go/Gin agent management service
- `evo-ai-processor-community/` — [submodule] Python/FastAPI AI processing service
- `evo-ai-frontend-community/` — [submodule] React/TypeScript frontend
- `evo-bot-runtime/` — [submodule] Go/Gin bot pipeline service
- `evo-flow/` — [submodule] NestJS campaigns/journeys service
- `evo-nexus/` — [submodule] Multi-agent operating layer
- `evolution-api/` — [submodule] Node.js WhatsApp messaging provider
- `evolution-go/` — [submodule] Go WhatsApp messaging provider

## Technology Stack Summary

**Backend Services (4 languages, 6 services)**:
- **Ruby 3.4 + Rails 7.1** (evo-ai-crm-community, evo-auth-service-community) — REST APIs with Puma, Sidekiq background jobs, Doorkeeper OAuth, ActiveStorage, pgvector
- **Python 3.10 + FastAPI** (evo-ai-processor-community) — AI chat processing, A2A protocol, Alembic migrations
- **Go + Gin** (evo-ai-core-service-community, evo-bot-runtime) — Agent management, bot pipelines, JWT auth
- **TypeScript + NestJS** (evo-flow) — Campaigns, journeys, TypeORM, ClickHouse analytics

**Frontend**:
- **React + TypeScript + Vite** (evo-ai-frontend-community) — Modern SPA with opus-recorder, TinyMCE

**Infrastructure**:
- **PostgreSQL 16** with pgvector extension (shared database)
- **Redis** (caching, Sidekiq, session management)
- **ClickHouse** (evo-flow analytics)
- **Nginx** (API Gateway on port 3030)
- **MailHog** (dev email testing)
- **Docker Compose** (local dev, 9 services)
- **Docker Swarm** / **Traefik** (production deployment)
- **GitHub Actions** (CI, release pipeline)

## Core Framework Stack

| Layer | Technology | Services |
|-------|-----------|----------|
| **API Gateway** | Nginx (Alpine) with envsubst | All services routed through port 3030 |
| **Auth & RBAC** | Ruby Rails 7.1 + Doorkeeper OAuth 2.0 | evo-auth-service-community |
| **CRM Core** | Ruby Rails 7.1 API mode | evo-ai-crm-community |
| **AI Agent Mgmt** | Go + Gin | evo-ai-core-service-community |
| **AI Processing** | Python + FastAPI | evo-ai-processor-community |
| **Bot Automation** | Go + Gin | evo-bot-runtime |
| **Campaigns** | TypeScript + NestJS | evo-flow |
| **Frontend SPA** | React + TypeScript + Vite | evo-ai-frontend-community |
| **Messaging** | Node.js / Go | evolution-api, evolution-go |
| **Background Jobs** | Sidekiq | evo-ai-crm-community, evo-auth-service-community |

## UI & Interaction Libraries

- **React** with Vite for the web frontend
- **opus-recorder** for audio recording in chat
- **TinyMCE** for rich text editing
- **Nginx** serves the built frontend SPA in production

## Development Tools Overview

- **Docker Desktop** required for local development
- **Makefile** provides 20+ targets: `make setup`, `make start`, `make stop`, `make seed`, `make logs`, `make shell-crm`, etc.
- **setup.sh** — Interactive first-time bootstrap (copies `.env`, inits submodules, builds, seeds)
- **npm** used within the frontend and evo-flow submodules
- **GitHub Actions** for CI (PR validation) and release (multi-arch image builds)
- See `tooling.md` for detailed tool setup

## Getting Started Checklist

1. Clone with submodules: `git clone --recurse-submodules <repo-url>`
2. Run the setup script: `./setup.sh` (or manually: `cp .env.example .env`, `git submodule update --init --recursive`, `make setup`)
3. Start all services: `make start`
4. Seed the database: `make seed` (CRM first, then auth)
5. Access the frontend at `http://localhost:5173` and API gateway at `http://localhost:3030`
6. Review `development-workflow.md` for day-to-day tasks
7. Explore individual service `EXTENSION_POINTS.md` files for customization options

## Next Steps

- Read `architecture.md` for system design details
- Read `development-workflow.md` for branching and PR conventions
- Read `CONTRIBUTING.md` for contribution guidelines
- Visit https://docs.evolutionfoundation.com.br for official documentation
