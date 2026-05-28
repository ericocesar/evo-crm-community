---
type: skill
name: Security Audit
description: Review code and infrastructure for security weaknesses
skillSlug: security-audit
phases: [R, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Review nginx gateway configuration (`nginx/default.conf.template`) for CORS, headers, rate limiting, SSL
2. Audit auth service OAuth 2.0 / Doorkeeper implementation and JWT token handling
3. Verify all service endpoints enforce authentication (no unprotected admin routes)
4. Check RBAC enforcement: `account_owner` vs `agent` vs `super_admin` authorization
5. Scan for secrets exposure: `.env` files, hardcoded tokens, credentials in configs
6. Review database access patterns: SQL injection, parameterized queries
7. Check file upload security: ActiveStorage types, size limits, path traversal
8. Audit Docker security: non-root users, minimal images, exposed ports, volume permissions
9. Review third-party integrations: WhatsApp tokens, AI provider API keys
10. Document findings with severity (Critical/High/Medium/Low) per `SECURITY.md`

## Examples

**Evo CRM security audit report:**
```
## Security Audit Report — Evo CRM Community

### Critical
1. **Hardcoded API token in docker-compose.yml:42**
   - `EVOAI_CRM_API_TOKEN=evoai_dev_token` is committed to version control
   - Anyone with repo access can impersonate services
   - Fix: Remove hardcoded value, use `${EVOAI_CRM_API_TOKEN:-changeme}`

### High
2. **Missing rate limiting on /api/v1/auth/login**
   - nginx/default.conf.template has no rate limiting for login endpoint
   - Brute force attack vector for password guessing
   - Fix: Add `limit_req_zone` and `limit_req` directives

3. **CORS wildcard in nginx config:156**
   - `add_header Access-Control-Allow-Origin *;`
   - Allows any origin to make authenticated requests
   - Fix: Restrict to specific FRONTEND_URL origin

### Medium
4. **JWT tokens without expiration**
   - Auth service JWT defaults to no expiry in dev config
   - Tokens valid indefinitely if stolen
   - Fix: Set JWT_EXPIRATION in .env.example and enforce in code

5. **Database default credentials in production template**
   - .env.swarm.example uses `postgres/evoai_dev_password`
   - Must be changed before production deployment
   - Fix: Add prominent warning comment, generate random defaults in setup.sh

### Low
6. **Sidekiq dashboard exposed without auth**
   - Makefile shell-crm gives full Sidekiq dashboard access
   - Fix: Add basic auth to Sidekiq web UI route

### Recommendations
- Enable HSTS in nginx for production
- Add CSP headers for XSS prevention
- Implement request body size limits on all upstreams
- Rotate shared EVOAI_CRM_API_TOKEN on deployment
- Run dependency vulnerability scanner: bundle audit, pip-audit, npm audit, govulncheck
```

## Quality Bar

- Report critical vulnerabilities via security@evolutionfoundation.com.br — never in public issues
- Check OWASP Top 10: injection, broken auth, sensitive data exposure, XXE, access control, misconfig, XSS, deserialization, vulnerable deps, insufficient logging
- Verify auth on every API route defined in `nginx/default.conf.template`
- Scan all config files for hardcoded secrets: `.env`, `*.yml`, `*.yaml`, `*.json`, `*.rb`
- Check JWT validation in every service, not just auth service
- Audit Docker for non-root users and minimal base images
- Document findings with clear severity, impact, and actionable fixes

## Resource Strategy

- Primary security reference: `SECURITY.md` — vulnerability reporting procedure
- Infrastructure audit: `nginx/default.conf.template`, `docker-compose.yml`, `docker-compose.swarm.yaml`
- Auth audit: `evo-auth-service-community/` (Doorkeeper, JWT, RBAC)
- Secrets scan: `.env.example`, `.env.swarm.example`, all Docker Compose files
- Reference `.context/docs/security.md` for security architecture
- Add `scripts/` for automated secret scanning or dependency vulnerability checks
