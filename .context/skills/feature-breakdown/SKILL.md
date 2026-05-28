---
type: skill
name: Feature Breakdown
description: Break down features into implementable tasks
skillSlug: feature-breakdown
phases: [P]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Understand the full feature requirements and which service(s) are affected
2. Identify service ownership: CRM, Auth, Core, Processor, Bot Runtime, Flow, Frontend, or Gateway
3. Break into tasks ordered by dependency: database → backend → gateway routing → frontend → tests
4. For cross-service features, plan in this order: schema → auth → domain service → gateway route → frontend
5. Assign each task to a specific service submodule
6. Add acceptance criteria for each task
7. Flag cross-service coordination needs and seeding order implications

## Examples

**Evo CRM feature breakdown — WhatsApp Integration:**
```
## Feature: WhatsApp Messaging Channel

### Task 1: Database (crm)
- Add whatsapp_integrations table with account_id, phone_number_id, settings
- Add message_channel enum to conversations table
- Acceptance: Migration runs, make seed-crm succeeds

### Task 2: Backend — CRM Service
- POST /api/v1/accounts/:id/integrations/whatsapp → configure integration
- GET /api/v1/accounts/:id/integrations → list configured channels
- Acceptance: Can CRUD WhatsApp integrations

### Task 3: Backend — Processor Service
- WhatsApp provider adapter for evolution-api communication
- Webhook handler for incoming WhatsApp messages
- Outgoing message relay through evolution-api
- Acceptance: Can send/receive WhatsApp messages via API

### Task 4: Gateway Routing (nginx)
- Route /api/v1/agents/:id/integrations/whatsapp → processor:8000
- Route /api/v1/integrations/whatsapp/callback → processor:8000
- Acceptance: Routes work through gateway

### Task 5: Frontend
- WhatsApp integration settings UI in account settings
- WhatsApp message preview in chat interface
- Channel selector in conversation view
- Acceptance: Can configure WhatsApp and see messages in UI

### Dependencies:
Task 2 requires Task 1 (schema)
Task 3 requires Task 2 (integration config API)
Task 4 requires Task 2+3 (backend endpoints exist)
Task 5 requires Task 2+3+4 (full API available)
```

## Quality Bar

- Each task maps to a specific service submodule
- Tasks consider seeding order: CRM schema before auth tables
- Gateway routing is a separate task whenever new endpoints are added
- Database schema changes must be backward-compatible (shared DB)
- Frontend tasks depend on backend + gateway tasks being complete
- Acceptance criteria include API routes and expected responses
- Flag if feature spans multiple services (requires coordination)

## Resource Strategy

- Reference `.context/docs/architecture.md` for service boundaries
- Reference `nginx/default.conf.template` for existing route patterns
- Reference `.context/docs/data-flow.md` for cross-service data paths
- Add `scripts/` only for task generation automation
