---
slug: deployment
category: operations
generatedAt: 2026-05-28T12:54:08.039Z
relevantFiles:
  - docker-compose.prod-test.yaml
  - docker-compose.swarm.yaml
  - docker-compose.yml
  - nginx/Dockerfile
  - .github/workflows/ci.yml
  - .github/workflows/gateway-publish.yml
  - .github/workflows/release.yml
---

# How do I deploy this project?

## Deployment

### Docker

This project includes Docker configuration.

```bash
docker build -t app .
docker run -p 3000:3000 app
```

### CI/CD

CI/CD pipelines are configured for this project.
Check `.github/workflows/` or equivalent for pipeline configuration.