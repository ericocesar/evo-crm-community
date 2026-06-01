# Base de Conhecimento RAG — Estado Atual

> Mapeamento do que o projeto já tem implementado para fornecer uma base de conhecimento RAG para agents.
> Data: 2026-06-01.

O projeto **não usa n8n/Flowise/Pinecone/Qdrant/OpenSearch**. A implementação é um microserviço próprio no **evo-nexus** (Python/Flask) com **pgvector** no Postgres.

## Stack

| Camada | Tecnologia |
|---|---|
| Vector DB | **pgvector** (Postgres 15+, `pgvector/pgvector:pg16`) |
| Busca | **Híbrida**: HNSW cosine + BM25 tsvector + fusão RRF + `content_type_boosts` |
| Embeddings | **3 provedores**: local MPNet 768d (pt-BR) · OpenAI text-embedding-3 · Gemini gemini-embedding-001 |
| Parsing | **Marker-pdf** (PDF/DOCX/PPTX/XLSX/HTML/EPUB/imagens) + PlainText fallback |
| Chunking | Estrutural Markdown (H1-H3 + code/table/list) — 500/1000 tokens, overlap 10 |
| Migrations | **Alembic** (7 tabelas, HNSW + GIN indexes) |
| Auth | Dois níveis: `DASHBOARD_API_TOKEN` interno + `evo_k_<prefix>.<secret>` externo (bcrypt) |
| Criptografia | **Fernet** (`KNOWLEDGE_MASTER_KEY`) para connection strings |

## Hierarquia multi-tenant

```
Connection (Postgres) → Space (tenant) → Unit (tema/curso) → Document → Chunk
                                                              ↓
                                          prerequisites[], connections[]
```

## Integração com Agents (caminho principal)

**`evo-ai-processor-community/src/services/adk/tools/knowledge_nexus/search_tool.py`** expõe a KB como `FunctionTool` do Google ADK:

```python
create_knowledge_nexus_search_tool()
# POST {base_url}/api/knowledge/v1/spaces/{space_id}/search
# Header: Authorization: Bearer evo_k_<prefix>.<secret>
# Retorna: {status, total, results: [{doc_title, content, content_type, final_score}]}
```

Também há `HttpMemoryService` em `evo-ai-processor-community/src/services/memory_service.py` que delega ao microserviço de conhecimento.

## Configuração por Agent (frontend)

Em `evo-ai-frontend-community/src/pages/Customer/Agents/Agent/AgentEditPage.tsx:43-471` o agent aceita:
- `load_knowledge` — carrega KB
- `preload_knowledge` — pré-carrega no início
- `knowledge_tags` — filtro por tags
- `knowledge_base_config_id` — qual KB usar
- `knowledge_max_results` — top-k

## APIs REST

- **Interna** (`/api/knowledge/...`): connections, configure, test, migrate, health
- **Pública v1** (`/api/knowledge/v1/...`): spaces, units, documents, **search** (com API key)
- **Proxy** (`/api/dashboard/...`): bridge autenticado por sessão para o UI

## Frontend admin

`evo-nexus/dashboard/frontend/src/pages/Knowledge/`: Spaces, Units, Upload, Browse, Search, Settings, ApiKeys, Connections/{Detail,List,Wizard}. Wizard mostra fases: queued → scanning → parsing → chunking → embedding → storing → classifying → done.

## Skills Claude (evo-nexus/.claude/skills/knowledge-*/)

6 skills prontas: `knowledge-admin`, `knowledge-browse`, `knowledge-ingest`, `knowledge-organize`, `knowledge-query` (busca híbrida + síntese RAG com citações via Haiku 4.5), `knowledge-summarize`.

## Classificação assíncrona

`classify_worker.py` — subprocesso do Claude Code CLI que poll-a `knowledge_classify_queue` (ADR-008).

## Documentação

- `evo-nexus/docs/dashboard/knowledge.md` — doc principal (191 linhas)
- `evo-nexus/docs/dashboard/knowledge-database.md` — gotchas (Supabase/Neon, PgBouncer transacional não suportado)
- `evo-nexus/docs/dashboard/knowledge-base.md` — MemPalace (separado)

## Pendente / Diferido

| Item | Onde | Status |
|---|---|---|
| Segmentação por tópicos via LLM | `chunking.py:18-20` | TODO — "deferred to v1.1" |
| LlamaParse parser | `llamaparse_parser.py` | Stub — "deferred to v1.1" |
| Skill de reindex | `.env.example:165-175` | "planned for v0.25.1" |

## Dois sistemas RAG coexistem (intencional)

1. **Knowledge** (canônico) — pgvector, multi-tenant, API-first, híbrido. **Usado pelos agents.**
2. **MemPalace** — ChromaDB local, apenas notas pessoais (`dashboard/data/mempalace/chroma`, collection `mempalace_drawers`). Não é multi-tenant.

## Artefatos legados

`qdrant-client==1.14.2` ainda aparece em `evo-ai-processor-community/requirements.txt:148` e `pyproject.toml:44`, mas não é mais configurado em lugar nenhum (Pinecone/Qdrant/OpenSearch foram removidos; comentário em `.env.example` confirma).

---

## Resumo para agents

O agent (Google ADK) chama `FunctionTool` → POST `/api/knowledge/v1/spaces/{id}/search` → busca híbrida (HNSW+BM25+RRF) → retorna top-k com `doc_title, content, final_score`. O agent injeta isso no prompt. Tudo configurável por UI em `evo-ai-frontend`.
