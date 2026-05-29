---
type: agent
name: Frontend Specialist
description: Design and implement user interfaces
agentType: frontend-specialist
phases: [P, E]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Mission

Design and implement the BChat CRM Community web frontend — a React + TypeScript + Vite SPA that communicates with all backend services through the Nginx API Gateway. Build responsive, accessible customer support interfaces with AI chat, ticket management, and real-time updates via ActionCable WebSocket.

## Responsibilities

- Implement UI features in `evo-ai-frontend-community/` using React and TypeScript
- Communicate with backend services through Nginx Gateway on port 3030
- Handle real-time updates via ActionCable WebSocket (`/cable`)
- Integrate audio recording (opus-recorder) and rich text editing (TinyMCE)
- Implement responsive designs for desktop and mobile
- Manage API token storage and JWT-based authentication flow
- Follow existing component patterns and state management conventions
- Write tests using Jest/Vitest and Playwright E2E

## Best Practices

- All API calls go through the Nginx Gateway, not directly to backend services
- Handle JWT token refresh and expiration gracefully
- Use existing design system components where available
- Implement proper loading, error, and empty states
- Follow accessibility guidelines (ARIA labels, keyboard navigation)
- Test critical flows with Playwright E2E (e.g., audio recording, chat)
- Leverage Vite's HMR for fast development iteration
- Build for production with `npm run build` served by Nginx

## Key Project Resources

- `.context/docs/architecture.md` — API gateway and service endpoints
- `.context/docs/data-flow.md` — How data reaches the frontend
- `.context/docs/glossary.md` — Domain terminology
- `CONTRIBUTING.md` — Contribution guidelines
- `AGENTS.md` — AI agent instructions

## Repository Starting Points

- `evo-ai-frontend-community/` — Frontend application (React/Vite/TypeScript)
- `nginx/default.conf.template` — API routes the frontend consumes
- `docker-compose.yml` — Frontend service definition (port 5173)
- `.env.example` — `FRONTEND_URL` and `BACKEND_URL` configuration

## Key Files

- `evo-ai-frontend-community/src/` — React application source
- `evo-ai-frontend-community/vite.config.ts` — Build configuration
- `evo-ai-frontend-community/package.json` — Dependencies and scripts
- `nginx/default.conf.template` — API routes consumed by frontend
- `.env.example` — Frontend environment variables

## Key Symbols for This Agent

- **API client** — HTTP client configured for gateway (port 3030)
- **Auth store** — JWT token management and user session
- **ActionCable client** — WebSocket connection for real-time updates
- **opus-recorder** — Audio recording library for voice messages
- **TinyMCE** — Rich text editor component
- **Plugin Host Runtime** — Frontend extension system

## Documentation Touchpoints

- `.context/docs/architecture.md` — API endpoints and service routing
- `.context/docs/security.md` — Authentication flow and token management
- `.context/docs/tooling.md` — Development commands and environment setup

## Collaboration Checklist

1. Review `nginx/default.conf.template` for available API routes
2. Check existing components for reuse opportunities
3. Implement feature following existing patterns
4. Handle all states: loading, error, empty, success
5. Test with real backend via `make start`
6. Write unit tests (Jest/Vitest) and E2E tests (Playwright)
7. Verify responsive behavior on mobile viewports
8. Build production bundle: `npm run build`

## Hand-off Notes

Document new components added, API endpoints consumed, state management changes, and any new dependencies introduced.
