---
type: skill
name: Documentation
description: Generate and update technical documentation
skillSlug: documentation
phases: [P, C]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Identify the target audience (developers, operators, contributors, users)
2. Determine which doc file(s) need updating: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `.context/docs/*.md`, `docs/*.md`, service `EXTENSION_POINTS.md`
3. Use concrete paths, file references with line numbers, and working command examples
4. Follow existing document structure and tone conventions
5. Cross-reference related documents with links
6. Verify code examples work with `make start` and curl against gateway (port 3030)
7. Follow Conventional Commits: `docs: description`

## Examples

**BChat CRM API endpoint documentation:**
```
## GET /api/v1/agents

Returns a paginated list of AI agents for the current account.

### Authentication
Requires Bearer token (JWT) from auth service.

### Query Parameters
| Param    | Type   | Default | Description           |
|----------|--------|---------|-----------------------|
| page     | number | 1       | Page number           |
| per_page | number | 20      | Items per page (max 100) |
| folder_id| string | —       | Filter by folder      |

### Response (200 OK)
{
  "data": [
    {
      "id": "ag_abc123",
      "name": "Support Agent",
      "folder_id": "f_xyz",
      "mcp_servers": ["mcp_1"],
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 1 }
}

### Route (nginx/default.conf.template:142)
location /api/v1/agents {
    proxy_pass http://core:5555;
}
```

**Changelog entry:**
```
## v1.0.0-rc4 (2024-XX-XX)

### Added
- CRM: bulk ticket assignment for agents
- Processor: A2A protocol support for multi-agent conversations

### Fixed
- Auth: JWT token not refreshing on 401 response
- Gateway: CORS headers missing on /api/v1/bot-runtime routes

### Changed
- Frontend: upgraded TinyMCE to v7.x
```

## Quality Bar

- Write for the audience's knowledge level (developer vs. operator vs. end user)
- Include working, copy-pasteable commands verified against the gateway
- Use consistent terminology from `glossary.md`
- Link to actual files with line numbers
- Update docs in the same PR as code changes
- Cross-link new scaffolds in `docs/README.md` and `agents/README.md`
- Document both umbrella-level changes and service-specific changes

## Resource Strategy

- Primary docs: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`
- AI agent docs: `.context/docs/*.md` (8 structured docs)
- Service docs: Each submodule's `EXTENSION_POINTS.md` and `README.md`
- User-facing docs: `docs/` directory
- Add `scripts/` only for doc generation or link checking automation
