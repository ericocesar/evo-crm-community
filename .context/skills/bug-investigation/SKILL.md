---
type: skill
name: Bug Investigation
description: Systematic bug investigation and root cause analysis
skillSlug: bug-investigation
phases: [E, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Reproduce the bug with `make start` and relevant API calls through gateway (port 3030)
2. Check service logs: `make logs SERVICE=<name>` for error output
3. Trace the request path: Client → Nginx Gateway → Target Service → Database/Redis
4. Check nginx routing in `nginx/default.conf.template` for misconfiguration
5. Verify JWT token forwarding and inter-service auth
6. Check shared PostgreSQL and Redis state
7. Identify affected service and root cause
8. Document findings and plan minimal fix with regression test

## Examples

**BChat CRM bug investigation:**
```
## Bug: AI chat endpoint returns 502

### Reproduction:
1. Start services: make start
2. POST /api/v1/chat/sessions with valid JWT
3. Returns 502 Bad Gateway after 60s

### Investigation:
- make logs SERVICE=processor → "Connection refused to core:5555"
- nginx/default.conf.template: proxy_pass for /api/v1/chat routes to processor
- Processor → Core communication fails: Core service not healthy
- docker compose ps → core service restarting (healthcheck failing)

### Root cause:
Core service migration failed (see core_logs.txt).
PostgreSQL schema not loaded for core tables.
CRM seed ran but core tables missing — seeding order issue.

### Fix approach:
1. Run core service migrations: docker compose exec core <migration command>
2. Or: make clean && make setup (full reset)
3. Add core migration step to Makefile seed target
```

## Quality Bar

- Always reproduce before investigating
- Trace full path through gateway: check nginx logs, service logs, DB logs
- Check `docker compose ps` for unhealthy services first
- Check `core_logs.txt` for known migration issues
- Verify submodule state: `git submodule status`
- Check if seeding order was maintained (CRM before auth)
- Document the root cause, not just the symptom
- Write a regression test with the fix

## Resource Strategy

- Use `make logs`, `make status`, `docker compose ps` for diagnostics
- Check `nginx/default.conf.template` for routing issues
- Reference `core_logs.txt` for known core service issues
- Add `scripts/` for reproducible diagnostic procedures
