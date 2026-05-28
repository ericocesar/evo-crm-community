---
type: doc
name: glossary
description: Project terminology, type definitions, domain entities, and business rules
category: glossary
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Glossary & Domain Concepts

This document defines domain-specific terminology, actors, entities, and business rules used across Evo CRM Community.

## Core Terms

| Term | Definition | Location |
|------|------------|----------|
| **Account** | Top-level organizational unit. Community edition is single-tenant (one account per installation). | `evo-auth-service-community/app/models/account.rb` |
| **Account Owner** | Primary administrator role with full permissions over the account. | Auth service RBAC |
| **Agent** (User) | Standard user role within an account (not to be confused with AI Agent). | Auth service RBAC |
| **AI Agent** | Configured AI assistant that handles customer conversations. Defined in Core service. | `evo-ai-core-service-community/` |
| **Super Admin** | Installation-level administrator (introduced in rc3+). Manages whitelabel, app configs, installation settings. | Auth + CRM services |
| **A2A (Agent-to-Agent)** | Protocol for communication between AI agents. Enables multi-agent conversations. | `evo-ai-processor-community/` |
| **MCP Server** | Model Context Protocol server — external tool server that AI agents can call. | `evo-ai-core-service-community/` |
| **Custom Tool** | User-defined tool/function that AI agents can invoke during conversations. | `evo-ai-core-service-community/` |
| **Bot Pipeline** | Automated workflow executed by the bot runtime for scheduled or event-driven actions. | `evo-bot-runtime/` |
| **Journey** | Customer journey / campaign workflow in evo-flow for tracking customer interactions. | `evo-flow/` |
| **Contact Event** | Analytics event recorded in ClickHouse for journey/campaign tracking. | `evo-flow/` |
| **Sidekiq** | Background job processor (Ruby) used by auth and CRM services for async tasks. | `evo-ai-crm-community/`, `evo-auth-service-community/` |
| **ActionCable** | Rails WebSocket framework providing real-time updates to the frontend. | `evo-ai-crm-community/` |
| **ActiveStorage** | Rails file attachment framework for handling uploads (images, documents). | `evo-ai-crm-community/` |
| **pgvector** | PostgreSQL extension for vector similarity search, used for AI embeddings. | PostgreSQL container |
| **Doorkeeper** | OAuth 2.0 provider gem for Rails, used by auth service. | `evo-auth-service-community/` |
| **Evolution API** | Companion Node.js project providing WhatsApp messaging integration. | `evolution-api/` |
| **Evolution Go** | Alternative Go-based WhatsApp messaging provider. | `evolution-go/` |
| **Evo Nexus** | Multi-agent operating layer for coordinating multiple AI agents. | `evo-nexus/` |

## Acronyms & Abbreviations

| Acronym | Expansion | Context |
|---------|-----------|---------|
| **RBAC** | Role-Based Access Control | User permission system in auth service |
| **MFA** | Multi-Factor Authentication | Authentication security in auth service |
| **OAuth 2.0** | Open Authorization 2.0 | Authentication protocol implemented by Doorkeeper |
| **JWT** | JSON Web Token | Bearer token format used for inter-service auth |
| **MCP** | Model Context Protocol | Standard protocol for AI agents to call external tools |
| **A2A** | Agent-to-Agent | Protocol for inter-agent communication |
| **SPA** | Single Page Application | Frontend architecture (React + Vite) |
| **GHCR** | GitHub Container Registry | Docker image hosting for releases |
| **ORM** | Object-Relational Mapping | ActiveRecord (Rails), TypeORM (NestJS), SQLAlchemy (Python), GORM (Go) |
| **CORS** | Cross-Origin Resource Sharing | HTTP headers for browser security, configured in Nginx |
| **TLS** | Transport Layer Security | HTTPS encryption via Traefik in swarm deployments |

## Personas / Actors

| Persona | Description | Primary Workflow |
|---------|-------------|-----------------|
| **Account Owner** | Organization administrator who configures the CRM, manages users, and sets up AI agents. | User management, agent configuration, account settings |
| **Support Agent** (User) | Customer support representative who handles tickets and uses AI-assisted chat. | Ticket management, chat with customers, AI agent assistance |
| **Super Admin** | Installation operator who manages whitelabel branding, app configuration, and platform-level settings. | Platform configuration, installation management |
| **End Customer** | External user who contacts support via integrated channels (WhatsApp, web chat). | Initiate conversations, receive AI/human responses |
| **Developer** | Engineer extending or deploying the platform. Uses extension points and plugin system. | Custom development, deployment, integration |

## Domain Rules & Invariants

1. **Single-Tenant Invariant**: Community edition supports exactly one account per installation. No tenant isolation logic exists.
2. **Seeding Order**: CRM schema must be loaded before auth seeds. `make seed-crm` must run before `make seed-auth`.
3. **Token Account Resolution**: Account context is resolved from JWT tokens, never from headers. Services must not accept `account-id` headers for authorization.
4. **Role Hierarchy**: Only two user roles exist: `account_owner` (full access) and `agent` (limited access). `super_admin` is a separate installation-level role.
5. **Environment Validation**: `BACKEND_URL` and `FRONTEND_URL` must be non-localhost in production. CRM refuses to boot with localhost URLs in production mode.
6. **Docker Tag Convention**: Git tags prefix with `v` (e.g., `v1.0.0-rc3`). Docker tags drop the `v` (e.g., `1.0.0-rc3`).
7. **Port Assignments**: Services use fixed ports: 3000 (CRM), 3001 (Auth), 3005 (Flow), 3030 (Gateway), 5173 (Frontend), 5432 (PostgreSQL), 5555 (Core), 6379 (Redis), 8000 (Processor), 8080 (Bot Runtime), 8123 (ClickHouse).
