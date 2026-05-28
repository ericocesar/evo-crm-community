---
type: doc
name: development-workflow
description: Day-to-day engineering processes, branching, and contribution guidelines
category: workflow
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Development Workflow

This repository is a Git submodule monorepo. Most development happens inside individual service submodules (evo-ai-crm-community, evo-ai-frontend-community, etc.), not at the umbrella level. The umbrella repo orchestrates services for local development via Docker Compose, pins submodule versions, and manages cross-cutting concerns (CI/CD, gateway config, documentation). When making changes:

1. Identify which submodule(s) need changes
2. Work inside the submodule directory with its own toolchain
3. Test changes locally using `make start` and `make logs`
4. Commit in the submodule, push its branch, then update the umbrella repo's submodule pin

## Branching & Releases

- **main**: Stable, production-ready. Protected branch. Only merged from `develop` via PR.
- **develop**: Integration branch. All feature/fix branches merge here.
- **feat/***, **fix/***, **docs/***, **refactor/***: Short-lived feature branches branched from `develop`.
- **Release Tags**: Git tags use `v` prefix (e.g., `v1.0.0-rc3`). Docker tags drop the `v` (e.g., `1.0.0-rc3`).
- **Release Flow**: Pushing a `v*.*.*` tag triggers `.github/workflows/release.yml`, which builds and pushes all 5 service images to GHCR.
- **PRs**: Open PRs against `develop` or `main` (hotfixes). CI validates Docker Compose config and lints Dockerfiles.
- **Conventional Commits**: All commits follow Conventional Commits format: `feat(scope):`, `fix(scope):`, `docs:`, `refactor:`, `test:`, `chore:`.

## Local Development

```bash
# First-time setup
git clone --recurse-submodules <repo-url>
./setup.sh
# Or manually:
cp .env.example .env
make setup

# Day-to-day
make start          # Start all services (docker compose up -d)
make stop           # Stop all services
make restart        # Stop + start
make build          # Rebuild all images (no cache)
make status         # Check service health
make logs           # View all logs
make logs SERVICE=crm  # View specific service logs

# Database
make seed           # Run all seeds (CRM first, then auth)
make seed-crm       # Create DB, load schema, seed CRM only
make seed-auth      # Seed auth only (default user)

# Shell access
make shell-crm      # Bash in CRM container
make shell-auth     # Bash in auth container
make shell-core     # Shell in core container
make shell-processor # Bash in processor container
make shell-bot-runtime # Shell in bot-runtime container

# Submodule management
git submodule update --init --recursive  # Pull all submodules
git submodule update --remote            # Update to latest remote commits
```

## Code Review Expectations

- All PRs require at least one review before merging
- Reviewers should verify: Conventional Commits format, no secrets in code, submodule pins are correct, Docker Compose changes are valid, and documentation is updated
- CI must pass (Docker Compose validation + Hadolint linting)
- Reference `CONTRIBUTING.md` for full contribution guidelines
- Reference `AGENTS.md` for AI agent collaboration tips
- Cross-link new scaffolds in `docs/README.md` and `agents/README.md`

## Testing Expectations

- There is no umbrella-level test suite. Testing is handled within each submodule.
- Run service-specific tests inside each submodule:
  - **Ruby services**: `bundle exec rspec` or `bundle exec rails test`
  - **Python processor**: `pytest`
  - **Go services**: `go test ./...`
  - **Frontend**: `npm run test` (Jest/Vitest), `npx playwright test` for E2E
  - **NestJS (evo-flow)**: `npm run test`
- Before opening a PR, verify tests pass in the affected submodule(s)
- See `testing-strategy.md` for detailed testing guidance

## Onboarding Tasks

1. Read `README.md` and `project-overview.md` for project context
2. Run `./setup.sh` to bootstrap the local environment
3. Explore the API via `http://localhost:3030` (gateway) and frontend at `http://localhost:5173`
4. Review `architecture.md` for system design
5. Browse `nginx/default.conf.template` to understand API routing
6. Check each service's `EXTENSION_POINTS.md` for customization options
7. Pick up a `good first issue` from GitHub Issues
