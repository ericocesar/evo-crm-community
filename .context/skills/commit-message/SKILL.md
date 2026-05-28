---
type: skill
name: Commit Message
description: Generate commit messages following conventional commits and repository scope conventions
skillSlug: commit-message
phases: [E, C]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Review the staged changes using `git diff --staged`
2. Identify the type: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`, `ci`, `build`
3. Determine the scope — use the affected service or component:
   - `crm`, `auth`, `core`, `processor`, `bot-runtime`, `flow`, `frontend`, `nginx`, `docker`, `ci`, `docs`, `scaffolding`
4. Write a concise subject line (50 chars max, imperative mood, lowercase)
5. Add body if needed explaining motivation, not implementation details
6. Reference issue numbers with `Closes #X` or `Fixes #X`

## Examples

**Evo CRM project commits:**

```bash
# Feature in a specific service
feat(crm): add ticket priority field

# Bug fix with scope
fix(processor): handle timeout in AI chat sessions

# Cross-service feature
feat(nginx): route super admin endpoints to correct service

# Documentation
docs: add setup guide for Docker Swarm deployment

# Refactoring
refactor(auth): extract token validation middleware

# CI/CD
ci: add Hadolint linting for gateway Dockerfile

# Scaffolding (dotcontext)
feat(scaffolding): add doc links to agent playbooks

# Submodule update
chore: pin crm submodule to v1.0.0-rc3

# Docker infrastructure
build(docker): add healthcheck to core service
```

## Quality Bar

- Use imperative mood: "add" not "added" or "adds"
- Keep subject line under 50 characters
- Separate subject from body with blank line
- Scope should be the affected service or component name
- Reference issues with `Closes #X` or `Fixes #X`
- One logical change per commit
- Don't end subject line with period
- Valid scopes: `crm`, `auth`, `core`, `processor`, `bot-runtime`, `flow`, `frontend`, `nginx`, `docker`, `ci`, `docs`, `scaffolding`, plus generic scopes when cross-cutting

## Resource Strategy

- Reference `CONTRIBUTING.md` for project-specific commit conventions
- Add `scripts/` only for automated commit message generation
- Keep scope list aligned with actual service names in `.gitmodules`
