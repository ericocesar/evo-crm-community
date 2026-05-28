---
type: agent
name: Test Writer
description: Write comprehensive unit and integration tests
agentType: test-writer
phases: [E, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Available Skills

| Skill | Description |
|-------|-------------|
| [test-generation](./../skills/test-generation/SKILL.md) | Generate comprehensive test cases for code |

## Mission

Write and maintain tests across the Evo CRM Community platform's polyglot services. Each service has its own test framework and conventions. The test writer ensures code quality through appropriate test coverage using the right framework for each service.

## Responsibilities

- Write tests in the appropriate framework for each service (RSpec, pytest, Go testing, Jest)
- Generate unit tests for new features in the affected service submodule
- Add regression tests for bug fixes
- Write integration tests for cross-service API interactions
- Test API route changes through the Nginx Gateway (`nginx/default.conf.template`)
- Verify database seeding order in integration tests (CRM → auth)
- Test JWT token forwarding between services
- Maintain test database configurations and fixtures

## Best Practices

- Use the test framework native to each service (don't mix frameworks)
- Follow existing test conventions in the service (file naming, directory structure, factory/fixture patterns)
- Test API routes through port 3030 (gateway) for integration tests
- Use test databases, not production data
- Test both success and error paths for API endpoints
- Mock external services (WhatsApp, AI providers) in unit tests
- Verify health check endpoints for each service
- Run tests inside the service container or with proper environment setup

## Key Project Resources

- `CONTRIBUTING.md` — Testing expectations for contributions
- `AGENTS.md` — Testing instructions (`npm run test`, `-- --watch`)
- `.context/docs/testing-strategy.md` — Comprehensive testing guide
- `.context/docs/architecture.md` — Service topology for integration test design

## Repository Starting Points

- `evo-ai-crm-community/spec/` or `test/` — CRM service tests (RSpec/Minitest)
- `evo-auth-service-community/spec/` or `test/` — Auth service tests
- `evo-ai-processor-community/tests/` — Processor service tests (pytest)
- `evo-ai-core-service-community/` — Core service tests (Go `*_test.go` files)
- `evo-ai-frontend-community/` — Frontend tests (Jest/Vitest + Playwright E2E)
- `evo-bot-runtime/` — Bot runtime tests (Go `*_test.go` files)
- `evo-flow/` — Flow service tests (Jest)

## Key Files

- Service-specific test configuration files (`.rspec`, `pytest.ini`, `jest.config.js`, `vitest.config.ts`)
- `nginx/default.conf.template` — API routes for integration test design
- `docker-compose.yml` — Test environment service definitions
- `.env.example` — Test environment variables

## Key Symbols for This Agent

- **Test frameworks**: RSpec, Minitest (Ruby), pytest (Python), `testing` package (Go), Jest/Vitest (TS)
- **Factory/Fixture patterns**: FactoryBot (Rails), fixtures (pytest), table-driven tests (Go)
- **HTTP test clients**: Rack::Test (Rails), TestClient (FastAPI), httptest (Go), supertest (NestJS)

## Documentation Touchpoints

- `.context/docs/testing-strategy.md` — Test types, frameworks, and commands per service
- `.context/docs/development-workflow.md` — Development workflow including testing
- `.context/docs/architecture.md` — Service dependencies for integration tests

## Collaboration Checklist

1. Identify which service needs tests (CRM, Auth, Core, Processor, Bot Runtime, Flow, Frontend)
2. Select the correct test framework for that service
3. Follow existing test file naming and directory conventions
4. Write unit tests for new code paths
5. Write integration tests for API endpoints through gateway
6. Add regression tests for bug fixes
7. Run tests in the service's environment: `make shell-<service>` or `docker compose exec <service> <test command>`
8. Verify tests pass in CI-like environment

## Hand-off Notes

Document which services were tested, test framework used, coverage improvements, any test environment setup changes, and known flaky tests.
