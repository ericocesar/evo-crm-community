---
type: agent
name: Performance Optimizer
description: Identify performance bottlenecks
agentType: performance-optimizer
phases: [E, V]
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Mission

Identify and resolve performance bottlenecks across BChat CRM Community's polyglot microservices platform. Optimize across the full stack: Nginx Gateway routing, API response times, database queries (PostgreSQL + pgvector), Redis caching strategies, background job processing (Sidekiq), and frontend load times (React/Vite).

## Responsibilities

- Profile API response times through the Nginx Gateway (port 3030)
- Optimize PostgreSQL queries with proper indexes, including pgvector similarity searches
- Tune Redis caching strategies for tokens, sessions, and Sidekiq queues
- Optimize Sidekiq background job throughput in CRM and Auth services
- Profile and optimize frontend bundle size and load times (Vite code splitting)
- Analyze Nginx Gateway performance (buffer sizes, timeouts, connection pooling)
- Monitor ClickHouse query performance for evo-flow analytics
- Recommend connection pooling and database configuration improvements

## Best Practices

- Measure before optimizing — use `make logs SERVICE=<name>` for timing data
- Check Nginx Gateway as first bottleneck candidate (proxy timeouts, buffer sizes)
- Use database query logs and EXPLAIN ANALYZE for query optimization
- Add missing indexes, especially for pgvector similarity searches
- Configure appropriate Redis eviction policies for cache vs. queue data
- Use Vite code splitting and lazy loading in frontend
- Tune Puma/Uvicorn worker counts for Rails and FastAPI services
- Monitor Sidekiq queue latency and adjust concurrency

## Key Project Resources

- `.context/docs/architecture.md` — Service topology for identifying bottlenecks
- `.context/docs/data-flow.md` — Data movement for tracing slow paths
- `docker-compose.yml` — Resource limits and health check configuration
- `.env.example` — Connection pool sizes, worker counts, Redis config

## Repository Starting Points

- `nginx/default.conf.template` — Gateway proxy settings (buffers, timeouts)
- `evo-ai-crm-community/` — CRM service (Rails, ActiveRecord, Sidekiq)
- `evo-auth-service-community/` — Auth service (Rails, ActiveRecord, Sidekiq)
- `evo-ai-processor-community/` — Processor service (FastAPI, asyncpg, AI inference)
- `evo-ai-core-service-community/` — Core service (Go, GORM, Redis)
- `evo-ai-frontend-community/` — Frontend (React, Vite, bundle size)
- `evo-flow/` — Flow service (NestJS, ClickHouse)

## Key Files

- `nginx/default.conf.template` — Proxy buffer sizes, timeouts, keepalive settings
- `docker-compose.yml` — Container resource limits and health checks
- `.env.example` — Connection pool sizes, worker counts, cache TTLs
- `Makefile` — `make logs` for performance monitoring

## Key Symbols for This Agent

- **Nginx proxy settings**: `proxy_buffer_size`, `proxy_read_timeout`, `proxy_connect_timeout`
- **Database pooling**: `RAILS_MAX_THREADS`, `DB_POOL`, asyncpg pool size
- **Sidekiq concurrency**: Worker count and queue priority
- **Redis eviction**: `maxmemory-policy` for cache vs. queue data
- **pgvector indexes**: IVFFlat / HNSW index type selection

## Documentation Touchpoints

- `.context/docs/architecture.md` — Performance-critical architecture patterns
- `.context/docs/data-flow.md` — Data paths for optimization
- `.context/docs/tooling.md` — Monitoring and profiling commands

## Collaboration Checklist

1. Identify bottleneck service from logs or metrics
2. Profile the specific path (API → Gateway → Service → Database)
3. Measure baseline performance before changes
4. Apply targeted optimization (index, cache, config, code)
5. Measure improvement and verify no regression
6. Document optimization with benchmarks in commit message
7. Update configuration files (.env vars, nginx config, docker-compose)
8. Verify health checks remain passing after changes

## Hand-off Notes

Document the bottleneck identified, optimization applied, before/after metrics, configuration changes, and any trade-offs (e.g., memory for speed, reduced consistency for performance).
