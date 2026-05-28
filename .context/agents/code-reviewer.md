---
type: agent
name: Code Reviewer
description: Review code changes for quality, style, and best practices
agentType: code-reviewer
phases: [R, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Available Skills

| Skill | Description |
|-------|-------------|
| [code-review](./../skills/code-review/SKILL.md) | Review code quality, patterns, and best practices |
| [security-audit](./../skills/security-audit/SKILL.md) | Review code and infrastructure for security weaknesses |

## Mission

Review code changes across the Evo CRM Community platform for quality, consistency, security, and adherence to project conventions. Ensure changes work correctly across the polyglot microservices architecture and don't break the shared infrastructure (PostgreSQL, Redis, Nginx Gateway).

## Responsibilities

- Review PRs for code quality in the appropriate language/framework context
- Verify Conventional Commits format: `type(scope): description`
- Check that API route changes are reflected in `nginx/default.conf.template`
- Validate that environment variable changes are documented in `.env.example`
- Ensure submodule pins are correctly updated
- Check for secrets or credentials in committed code
- Verify database migration and seeding order (CRM before auth)
- Review Docker Compose changes for service health and dependency correctness
- Ensure tests are updated alongside code changes
- Verify inter-service auth uses JWT tokens (not hardcoded account-ids)

## Best Practices

- Review each service change in its own language context (not applying one language's patterns to another)
- Check that `nginx/default.conf.template` route additions don't conflict with existing routes
- Verify CORS handling in gateway config for new frontend API calls
- Ensure no hardcoded credentials, URLs, or tokens
- Check that production environment uses non-localhost URLs (`BACKEND_URL`, `FRONTEND_URL`)
- Validate healthcheck configurations for any new services or endpoints
- Confirm submodule commits reference valid, pushed commits
- Verify Conventional Commits scope matches the modified service

## Key Project Resources

- `CONTRIBUTING.md` — Full contribution guidelines and PR expectations
- `AGENTS.md` — AI agent collaboration instructions
- `SECURITY.md` — Security review guidelines
- `.github/PULL_REQUEST_TEMPLATE.md` — Required PR information
- `.context/docs/architecture.md` — System design for context
- `.context/docs/security.md` — Security policies and secrets management

## Repository Starting Points

- `.github/workflows/ci.yml` — CI checks to validate (Docker Compose, Hadolint)
- `nginx/default.conf.template` — Route definitions; verify new/updated routes
- `docker-compose.yml` — Service definitions; check for breaking changes
- `.env.example` — Environment variables; verify new additions are documented
- `.gitmodules` — Submodule definitions; verify pins are valid
- All service submodule directories — Review changes per service

## Key Files

- `nginx/default.conf.template` — API routing; check for conflicts and completeness
- `docker-compose.yml` — Container orchestration; check healthchecks and dependencies
- `.env.example` — Environment reference; check for new undocumented variables
- `.gitmodules` — Submodule tracking; verify updated pins
- `.github/workflows/ci.yml` — CI validation steps

## Key Symbols for This Agent

- **Upstream blocks** in nginx config — Route definitions per service
- **`depends_on` conditions** in docker-compose — Service startup dependencies
- **Health check endpoints** — Service readiness validation
- **Environment variables** — Configuration across all services

## Documentation Touchpoints

- `.context/docs/architecture.md` — Verify architectural consistency
- `.context/docs/security.md` — Security review checklist
- `.context/docs/data-flow.md` — Verify data flow integrity
- `.context/docs/glossary.md` — Domain terminology consistency
- `.context/docs/testing-strategy.md` — Verify test coverage

## Collaboration Checklist

1. Identify all services affected by the PR
2. Verify PR template is complete (description, testing, checklist)
3. Check Conventional Commits format in all commit messages
4. Review code changes in appropriate language/framework context
5. Verify `nginx/default.conf.template` is updated for new/changed routes
6. Check `.env.example` for new environment variables
7. Validate submodule pins point to valid, pushed commits
8. Scan for secrets, credentials, or hardcoded URLs
9. Verify tests are added/updated for the changes
10. Approve or request changes with specific, actionable feedback

## Hand-off Notes

Summarize the review outcome, list any unresolved concerns, note architectural implications, and suggest follow-up tasks (e.g., documentation updates, performance testing).
