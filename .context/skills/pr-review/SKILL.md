---
type: skill
name: PR Review
description: Review pull requests against team standards and best practices
skillSlug: pr-review
phases: [R, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Read the PR description and verify `.github/PULL_REQUEST_TEMPLATE.md` sections are filled
2. Check which service(s) the PR modifies (CRM, Auth, Core, Processor, Bot Runtime, Flow, Frontend, Gateway)
3. Verify CI passes: Docker Compose validation + Hadolint linting
4. Review code in the appropriate language/framework context
5. Check `nginx/default.conf.template` is updated for new/changed routes
6. Validate `.env.example` has new environment variables documented
7. Verify submodule pins point to valid, pushed commits
8. Confirm Conventional Commits format in all commit messages
9. Leave constructive feedback — distinguish required from suggested
10. Approve or request changes

## Examples

**BChat CRM approval comment:**
```
Looks good! Feature implementation covers all layers correctly.

### What was checked:
- CRM service: tickets API follows existing patterns ✓
- nginx/default.conf.template: new /api/v1/tickets routes added ✓
- .env.example: no new env vars needed ✓
- Submodule pin: evo-ai-crm-community updated to feat/tickets branch ✓
- Tests: RSpec request specs added for all new endpoints ✓
- Commits: follow Conventional Commits (feat(crm): ...) ✓
- CI: docker compose config and Hadolint pass ✓

Minor suggestion: Consider adding pagination to GET /api/v1/tickets
before it reaches production load. Non-blocking.

Approved
```

**Request changes:**
```
Found issues that need attention before merging:

1. **nginx routing missing**: New endpoint POST /api/v1/tickets/bulk
   has no route in nginx/default.conf.template. The frontend won't
   be able to reach it through the gateway.

2. **Submodule pin**: evo-ai-crm-community submodule points to a local
   commit that hasn't been pushed to the remote. CI will fail.

3. **Missing test**: The Sidekiq worker for ticket assignment has no
   test coverage. Please add a spec covering success and failure cases.

Address these and I'll re-review.
```

## Quality Bar

- Verify PR template is complete: description, testing notes, checklist items
- Check CI status before reviewing
- Review each service change in its own language context
- Check nginx routing for every API change
- Validate submodule pins are valid, pushed commits
- Scan for hardcoded secrets, credentials, or URLs
- Verify Conventional Commits format on all commits
- Distinguish blocking issues from suggestions
- Test locally if the change is complex or cross-service

## Resource Strategy

- Reference `.github/PULL_REQUEST_TEMPLATE.md` for required PR sections
- Reference `CONTRIBUTING.md` for contribution standards
- Reference `.context/docs/security.md` for security review checklist
- Reference `.context/docs/architecture.md` for architectural patterns
