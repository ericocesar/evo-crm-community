---
type: doc
name: testing-strategy
description: Test frameworks, patterns, coverage requirements, and quality gates
category: testing
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Testing Strategy

Evo CRM Community is a polyglot monorepo where each service maintains its own test suite. There is no umbrella-level test framework. Testing is the responsibility of each submodule's development team, using the language-appropriate framework. CI validates Docker Compose configuration and lints Dockerfiles but does not execute service-level tests at the umbrella level.

## Test Types

### Unit Tests

| Service | Framework | File Convention | Command |
|---------|-----------|----------------|---------|
| CRM (Ruby/Rails) | RSpec / Minitest | `*_spec.rb` / `*_test.rb` | `bundle exec rspec` or `bundle exec rails test` |
| Auth (Ruby/Rails) | RSpec / Minitest | `*_spec.rb` / `*_test.rb` | `bundle exec rspec` or `bundle exec rails test` |
| Processor (Python) | pytest | `test_*.py` / `*_test.py` | `pytest` |
| Core (Go) | Go testing | `*_test.go` | `go test ./...` |
| Bot Runtime (Go) | Go testing | `*_test.go` | `go test ./...` |
| Frontend (React/TS) | Jest / Vitest | `*.test.ts` / `*.test.tsx` | `npm run test` |
| Flow (NestJS) | Jest | `*.spec.ts` | `npm run test` |

### Integration Tests

- **Rails services**: Integration tests using RSpec request specs or Minitest integration tests, typically requiring a test database
- **Python processor**: FastAPI TestClient for endpoint integration tests with test database
- **Go services**: HTTP handler tests using `httptest` package
- **NestJS**: E2E test utilities with supertest
- **Docker integration**: The umbrella CI validates Docker Compose configuration (`docker compose config`) and lints Dockerfiles with Hadolint

### E2E Tests

- **Frontend**: Playwright E2E tests for critical user flows (e.g., `e2e/audio-recording.spec.ts` mentioned in CHANGELOG)
- **Full-stack**: Run all services locally via `make start` and test through the API gateway on port 3030
- **No umbrella E2E suite**: Each service is responsible for its own end-to-end testing

## Running Tests

```bash
# Ruby services (inside submodule directory)
cd evo-ai-crm-community && bundle exec rspec
cd evo-auth-service-community && bundle exec rails test

# Python processor (inside submodule directory)
cd evo-ai-processor-community && pytest
cd evo-ai-processor-community && pytest --cov  # with coverage

# Go services (inside submodule directory)
cd evo-ai-core-service-community && go test ./...
cd evo-bot-runtime && go test ./...

# Frontend (inside submodule directory)
cd evo-ai-frontend-community && npm run test
cd evo-ai-frontend-community && npx playwright test  # E2E

# NestJS evo-flow (inside submodule directory)
cd evo-flow && npm run test
cd evo-flow && npm run test:e2e
```

## Quality Gates

- **Conventional Commits**: All commits must follow `feat(scope):`, `fix(scope):`, etc. format
- **CI Validation**: PRs against `main` and `develop` must pass:
  - Docker Compose configuration validation (`docker compose -f docker-compose.yml config`)
  - Docker Compose swarm configuration validation (`docker compose -f docker-compose.swarm.yaml config`)
  - Dockerfile linting (Hadolint on `nginx/Dockerfile`)
- **Code Review**: At least one reviewer required for all PRs
- **Submodule Pins**: Submodule references must be valid and point to existing commits
- **No Secrets**: `.env` files must not be committed; CI should fail on detected secrets
- **Service-Level Gates**: Each submodule may define its own quality gates (linting, coverage thresholds, etc.)

## Troubleshooting

- **Flaky Tests**: Individual submodule test suites may have flaky tests. Check service-specific CI and documentation.
- **Database State**: Integration tests that require a database should use test-specific database instances or transactional rollback
- **Port Conflicts**: Running multiple services locally can cause port conflicts. Ensure only one instance of each service is running.
- **Submodule State**: If tests fail unexpectedly, verify submodules are initialized: `git submodule update --init --recursive`
- **Docker Dependencies**: Services that depend on Docker containers for testing need the Docker daemon running
- **Environment Variables**: Test suites may require specific environment variables. Check each service's `.env.test` or equivalent configuration.
