---
type: skill
name: API Design
description: Design RESTful APIs following best practices
skillSlug: api-design
phases: [P, R]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Workflow

1. Identify which backend service owns the domain (CRM, Auth, Core, Processor, Bot Runtime, Flow)
2. Check `nginx/default.conf.template` for existing route patterns under the target service
3. Design URL structure following REST conventions: plural nouns, no verbs in paths
4. Define path prefix matching gateway routing (`/api/v1/<service-domain>/`)
5. Design request/response schemas consistent with the service's framework
6. Plan error handling — consistent JSON error format across services
7. Add route to `nginx/default.conf.template` upstream block for the service
8. Document new environment variables in `.env.example` if needed

## Examples

**Evo CRM API design — adding a new CRM endpoint:**
```
# Tickets API (routes through Nginx Gateway → evo-ai-crm-community:3000)

GET    /api/v1/tickets           # List tickets (paginated, filtered)
POST   /api/v1/tickets           # Create ticket
GET    /api/v1/tickets/:id       # Get ticket by ID
PUT    /api/v1/tickets/:id       # Update ticket
DELETE /api/v1/tickets/:id       # Delete ticket

# Nginx route addition (in nginx/default.conf.template):
location /api/v1/tickets {
    proxy_pass http://crm:3000;
    proxy_set_header Authorization $http_authorization;
}

# Response format (consistent across services):
{
  "data": { ... },
  "meta": { "page": 1, "per_page": 20, "total": 100 }
}

# Error format:
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Title is required",
    "details": [{ "field": "title", "message": "can't be blank" }]
  }
}
```

## Quality Bar

- Route through Nginx Gateway, never expose services directly
- Use nouns for resources, not verbs (`/tickets` not `/getTickets`)
- Version API from the start (`/api/v1/`)
- Use proper HTTP methods and status codes
- Check `nginx/default.conf.template` for existing patterns and conflicts
- Account context resolved from JWT token, never `account-id` headers
- Document new routes in service's `EXTENSION_POINTS.md`
- Use path prefix matching the gateway's service routing conventions

## Resource Strategy

- Add `scripts/` only for complex API generation or validation
- Add `references/` for OpenAPI/Swagger schemas if generated
- Keep route definitions in `nginx/default.conf.template` as the authoritative source
