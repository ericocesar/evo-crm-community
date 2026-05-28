---
type: skill
name: Code Review
description: Review code quality, patterns, and best practices
skillSlug: code-review
phases: [R, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Identify which service(s) the PR modifies (CRM, Auth, Core, Processor, Bot Runtime, Flow, Frontend, Gateway)
2. Review code in the appropriate language/framework context (not cross-language rules)
3. Verify `nginx/default.conf.template` is updated for new/changed routes
4. Check `.env.example` for new environment variables
5. Validate submodule pins are correct and point to valid commits
6. Scan for hardcoded secrets, credentials, URLs
7. Verify Conventional Commits format in all commit messages
8. Confirm tests are added/updated for the changes

## Examples

**Evo CRM code review feedback — nginx routing issue:**
```
Issue: Missing CORS headers for new frontend route

In nginx/default.conf.template:
  location /api/v1/new-endpoint {
-     proxy_pass http://crm:3000;
+     proxy_pass http://crm:3000;
+     add_header Access-Control-Allow-Origin $http_origin;
+     add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
  }

Other upstream blocks add CORS headers; this one was missed.
Without CORS, the frontend on a different origin cannot call this endpoint.
```

**Security feedback — hardcoded secret:**
```
Issue: Hardcoded API token in docker-compose.yml

- EVOAI_CRM_API_TOKEN=my-secret-token-here
+ EVOAI_CRM_API_TOKEN=${EVOAI_CRM_API_TOKEN:-changeme}

Always use environment variable substitution. Hardcoded tokens in version
control are a security risk. Document in .env.example with dev defaults.
```

## Quality Bar

- Focus on most impactful issues first (security, correctness, architecture)
- Review in the service's language context, not generic rules
- Check nginx routing for every API change
- Verify no hardcoded credentials in any file
- Confirm submodule pins are valid commits
- Validate Conventional Commits format
- Explain why something is a problem with project-specific context
- Provide concrete, actionable suggestions

## Resource Strategy

- Reference `.context/docs/security.md` for security review guidelines
- Reference `.context/docs/architecture.md` for architectural patterns
- Use `.github/PULL_REQUEST_TEMPLATE.md` as review checklist
- Add `scripts/` only for automated pre-review checks
