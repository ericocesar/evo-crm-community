---
type: doc
name: security
description: Security policies, authentication, secrets management, and compliance requirements
category: security
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Security & Compliance Notes

Evo CRM Community implements defense-in-depth security across the API Gateway, authentication service, and individual backend services. Security policies are documented in `SECURITY.md` and enforced through CI/CD checks, code review, and infrastructure configuration.

## Authentication & Authorization

- **OAuth 2.0 Provider**: The auth service (`evo-auth-service-community`) implements OAuth 2.0 via Doorkeeper. All API access requires Bearer token authentication.
- **JWT Tokens**: User sessions use JWT tokens issued by the auth service. Tokens are validated by every backend service on each request.
- **RBAC Model**: Role-Based Access Control with two user roles (`account_owner`, `agent`) plus an installation-level `super_admin` role (rc3+).
- **MFA Support**: Multi-Factor Authentication is available via the auth service at `/api/v1/mfa/*`.
- **Service-to-Service Auth**: Inter-service communication uses Bearer token forwarding + `EVOAI_CRM_API_TOKEN` shared secret. The gateway adds necessary headers.
- **Token Account Resolution**: No `account-id` headers are used. Account context is resolved exclusively from the JWT token payload.
- **Gateway-Level Security**: Nginx handles CORS headers, request size limits, and upstream authentication forwarding in `nginx/default.conf.template`.

## Secrets & Sensitive Data

| Secret | Storage | Rotation | Notes |
|--------|---------|----------|-------|
| `DATABASE_URL` / `POSTGRES_PASSWORD` | Environment variables (`.env`) | Manual | PostgreSQL credentials for all services |
| `EVOAI_CRM_API_TOKEN` | Environment variables (`.env`) | Manual | Shared secret for service-to-service auth |
| `SECRET_KEY_BASE` (Rails) | Environment variables (`.env`) | Manual | Rails session encryption key |
| `JWT_SECRET` | Environment variables (`.env`) | Manual | JWT signing key for auth service |
| `REDIS_PASSWORD` | Environment variables (`.env`) | Manual | Redis authentication |
| OAuth App Credentials | Environment variables (`.env`) | Manual | OAuth 2.0 client secrets |
| AI Provider API Keys | Environment variables (`.env`) | Manual | Keys for external LLM/AI services |
| WhatsApp Session Data | Redis / Service config | Automatic | Evolution API/Go session tokens |

**Security Practices**:
- `.env` files are excluded from version control via `.gitignore`
- `.env.example` and `.env.swarm.example` provide safe templates without real secrets
- Development credentials in `.env.example` are explicitly marked as dev-only and must be changed for production
- Docker Swarm deployments support Docker Secrets for production secret management
- The `SECURITY.md` file provides vulnerability reporting procedures via security@evolutionfoundation.com.br

## Compliance & Policies

- **License**: Apache 2.0 with additional brand-protection clauses (LOGO preservation, Usage Notification). See `LICENSE`, `NOTICE`, and `TRADEMARKS.md`.
- **Vulnerability Reporting**: Report security issues to security@evolutionfoundation.com.br. Do not open public issues for security vulnerabilities. See `SECURITY.md`.
- **Production Hardening**: Before deploying to production:
  - Change all default passwords and tokens from `.env.example`
  - Set `BACKEND_URL` and `FRONTEND_URL` to non-localhost production URLs
  - Enable HTTPS via Traefik TLS termination (swarm deployments)
  - Configure Docker Secrets for sensitive values
  - Set `RAILS_ENV=production` and `NODE_ENV=production`
  - Enable database connection pooling appropriate for production load
- **Data Privacy**: Customer conversation data is stored in PostgreSQL. File attachments via ActiveStorage. ClickHouse stores analytics events. No built-in data anonymization — implement as needed for GDPR compliance.
- **Access Control**: Use RBAC roles to limit access. Super admin operations are restricted via dedicated endpoints under `/api/v1/super_admin/`.

## Incident Response

- **Reporting**: Security incidents should be reported to security@evolutionfoundation.com.br
- **Service Logs**: All services log to stdout/stderr. Use `make logs` for real-time monitoring.
- **Health Monitoring**: Health endpoints at `/health`, `/ready`, `/healthz`, `/readyz` (processor service) provide uptime monitoring.
- **Database Backups**: PostgreSQL data persists in the `postgres_data` Docker volume. Implement regular backup strategy for production.
- **Redis Persistence**: Redis data for Sidekiq queues and sessions. AOF/RDB persistence should be configured for production.
