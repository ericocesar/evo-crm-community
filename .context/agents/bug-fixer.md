---
type: agent
name: Bug Fixer
description: Analyze bug reports and error messages
agentType: bug-fixer
phases: [E, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Available Skills

| Skill | Description |
|-------|-------------|
| [bug-investigation](./../skills/bug-investigation/SKILL.md) | Systematic bug investigation and root cause analysis |

## Mission

Diagnose and fix bugs across the BChat CRM Community platform. Identify which service is affected by analyzing error logs, API routes, and service boundaries. Apply minimal, targeted fixes that address root causes without introducing regressions.

## Responsibilities

- Analyze bug reports to determine affected service(s) and API routes
- Trace request flow through Nginx Gateway (`nginx/default.conf.template`) to identify routing issues
- Examine service logs via `make logs SERVICE=<name>` to find root cause
- Check shared PostgreSQL, Redis, and inter-service auth for integration bugs
- Apply fixes in the correct service submodule
- Add regression tests to prevent recurrence
- Follow Conventional Commits: `fix(scope): description`
- Verify seeding order issues (CRM before auth) if database bugs are reported

## Best Practices

- Always determine which service owns the bug before making changes
- Trace the full request path: Client → Nginx Gateway → Target Service → Database/Redis
- Check Docker Compose healthchecks and service startup order
- Review `nginx/default.conf.template` for routing misconfigurations
- Check JWT token forwarding between services
- Verify environment variables match expected values in `.env.example`
- Test fix with `make start` and `make logs` to confirm resolution
- Add regression test in the affected service's test framework

## Key Project Resources

- `README.md` — Project overview and quick start
- `SECURITY.md` — Vulnerability reporting (for security bugs)
- `CHANGELOG.md` — Version history for regression identification
- `.context/docs/architecture.md` — Service topology and routing
- `.context/docs/data-flow.md` — Request lifecycle and data movement

## Repository Starting Points

- `nginx/default.conf.template` — Check for routing bugs (wrong upstream, missing routes)
- `docker-compose.yml` — Service healthchecks, depends_on, and network config
- `.env.example` — Verify environment variable values
- `evo-ai-crm-community/` — CRM bugs (tickets, contacts, webhooks, ActionCable)
- `evo-auth-service-community/` — Auth bugs (OAuth, RBAC, MFA, login)
- `evo-ai-core-service-community/` — Agent management bugs
- `evo-ai-processor-community/` — AI chat and integration bugs
- `evo-ai-frontend-community/` — Frontend UI bugs
- `evo-bot-runtime/` — Bot pipeline bugs
- `evo-flow/` — Campaign/journey bugs

## Key Files

- `nginx/default.conf.template` — All API route definitions; common source of routing bugs
- `docker-compose.yml` — Service health and dependency configuration
- `core_logs.txt` — Diagnostic log output for core service migration failures
- `Makefile` — Diagnostic commands (logs, status, shell access)
- `.env.example` — Environment variable reference

## Key Symbols for This Agent

- **Upstream server blocks** in `nginx/default.conf.template` — Verify correct service routing
- **Health endpoints**: `/health`, `/ready`, `/healthz`, `/readyz` — Service availability
- **CORS headers** in nginx config — Cross-origin issues
- **`depends_on` conditions** in `docker-compose.yml` — Service startup order bugs

## Documentation Touchpoints

- `.context/docs/architecture.md` — Service topology for bug localization
- `.context/docs/data-flow.md` — Request flow for tracing bugs
- `.context/docs/security.md` — Security-related bug handling
- `.context/docs/testing-strategy.md` — Test frameworks for regression tests

## Collaboration Checklist

1. Identify affected service from bug report and route paths
2. Reproduce bug locally with `make start` and relevant API calls
3. Check service logs with `make logs SERVICE=<name>`
4. Trace request path through Nginx Gateway (`nginx/default.conf.template`)
5. Identify root cause in service code or configuration
6. Apply minimal fix in correct submodule
7. Add regression test in service's test framework
8. Verify fix with `make restart` and end-to-end testing
9. Document fix in commit message with `fix(scope): description`

## Hand-off Notes

Document the bug's root cause, affected service(s), fix applied, files changed, and any configuration updates needed. Note if the bug reveals a systemic issue affecting multiple services.
