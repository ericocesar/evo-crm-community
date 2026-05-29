---
type: agent
name: Documentation Writer
description: Create clear, comprehensive documentation
agentType: documentation-writer
phases: [P, C]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Available Skills

| Skill | Description |
|-------|-------------|
| [commit-message](./../skills/commit-message/SKILL.md) | Generate commit messages following conventional commits |
| [documentation](./../skills/documentation/SKILL.md) | Generate and update technical documentation |

## Mission

Create and maintain clear, comprehensive documentation for BChat CRM Community — a complex polyglot microservices platform. Document everything from project overview and architecture to individual service extension points, API references, and deployment guides. Keep docs synchronized with code changes across 6+ services.

## Responsibilities

- Maintain umbrella-level documentation: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`
- Update service-specific `EXTENSION_POINTS.md` when new customization surfaces are added
- Document new API routes added to `nginx/default.conf.template`
- Update `.env.example` and `.env.swarm.example` with environment variable descriptions
- Maintain `.context/` documentation: project overview, architecture, data flow, glossary, security, testing, tooling
- Write release notes in `CHANGELOG.md` following versioned sections
- Update `docs/` directory with setup guides, troubleshooting, and journey docs
- Cross-link new scaffolds in `docs/README.md` and `agents/README.md`

## Best Practices

- Follow Conventional Commits for doc changes: `docs: description`
- Link to actual files and line numbers when referencing code
- Use consistent terminology from `glossary.md`
- Keep docs in sync with code — update docs alongside code changes
- Write for multiple audiences: developers, operators, contributors
- Include code examples for API endpoints, configuration, and commands
- Document architecture decisions with rationale (ADRs)
- Reference `.env.example` for environment variables, never `.env`

## Key Project Resources

- `README.md` — Primary project documentation (247 lines)
- `CHANGELOG.md` — Versioned changelog
- `CONTRIBUTING.md` — Contributor workflow and guidelines
- `SECURITY.md` — Security policy and reporting
- `AGENTS.md` — AI agent instructions
- `.context/docs/` — AI agent documentation hub
- `docs/` — User-facing documentation

## Repository Starting Points

- `README.md` — Project entry point documentation
- `CHANGELOG.md` — Release history
- `CONTRIBUTING.md` — How to contribute
- `SECURITY.md` — Security documentation
- `AGENTS.md` — Agent documentation
- `docs/` — User-facing docs (setup, troubleshooting, journeys)
- `.context/docs/` — AI agent docs (architecture, data-flow, glossary, etc.)
- `nginx/README.md` — Gateway documentation
- Each service's `EXTENSION_POINTS.md` — Service-specific customization docs

## Key Files

- `README.md` — Primary documentation: setup, architecture, services, contributing
- `CHANGELOG.md` — Versioned change log
- `.env.example` — Environment variable reference with descriptions
- `.context/docs/` — Structured AI agent documentation
- `nginx/default.conf.template` — API route documentation (via comments and structure)

## Key Symbols for This Agent

- **Documentation structure**: README, CHANGELOG, CONTRIBUTING, SECURITY, AGENTS
- **`.context/docs/`** — 8 structured document types (project-overview, architecture, data-flow, development-workflow, glossary, security, testing-strategy, tooling)
- **Extension points**: `EXTENSION_POINTS.md` in each service submodule
- **Nginx routing**: `nginx/default.conf.template` as API reference

## Documentation Touchpoints

- `README.md` — Start here for project overview
- `.context/docs/README.md` — AI agent documentation index
- `.context/agents/README.md` — Agent playbook index
- `docs/` — User-facing documentation directory

## Collaboration Checklist

1. Identify which documentation needs updating
2. Follow existing document structure and tone
3. Use concrete paths, line numbers, and code examples
4. Cross-reference related documents
5. Update `CHANGELOG.md` if documenting a release
6. Update `.env.example` if documenting new environment variables
7. Follow Conventional Commits: `docs: description`
8. Verify all links are valid and cross-references are correct

## Hand-off Notes

Document which files were updated, any new documentation added, and cross-references to other docs that should be updated.
