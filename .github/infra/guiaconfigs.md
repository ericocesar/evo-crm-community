# Guia de Configs — Portainer (Docker Swarm)

Este documento explica como configurar os **Docker Configs** no Portainer antes de fazer o deploy da stack `evo_crm`.

## Stack

Arquivo: `.github/infra/prod-swarm.evo.yaml`

## Pré-requisitos no Servidor

Antes de usar o Portainer, execute no servidor:

```bash
# Inicializa o Docker Swarm (se ainda não estiver)
docker swarm init

# Cria as redes externas usadas pela stack
docker network create --driver overlay --attachable interna
docker network create --driver overlay --attachable externa
```

## Configs no Portainer

A stack usa **Docker Configs externos** (mesmo mecanismo que `evo_auth_setup_survey_model`).
Você deve criá-los no Portainer **antes** de fazer o deploy.

### Como criar um config no Portainer

1. Acesse **Configs** no menu lateral
2. Clique em **Add config**
3. Preencha o **Name** conforme a tabela abaixo
4. Cole o conteúdo do arquivo Ruby correspondente do repositório
5. Clique em **Create the config**

### Lista de Configs

| Nome do Config | Arquivo de conteúdo no repositório |
|---|---|
| `evo_auth_setup_survey_model` | `evo-auth-service-community/app/models/setup_survey_response.rb` |
| `evo_crm_dashboard_controller` | `evo-ai-crm-community/app/controllers/dashboard_controller.rb` |
| `evo_crm_inboxes_controller` | `evo-ai-crm-community/app/controllers/api/v1/inboxes_controller.rb` |
| `evo_crm_evolution_go_service` | `evo-ai-crm-community/app/services/whatsapp/providers/evolution_go_service.rb` |

### Alternativa via CLI

Se preferir criar os configs por linha de comando no servidor:

```bash
docker config create evo_auth_setup_survey_model ./evo-auth-service-community/app/models/setup_survey_response.rb
docker config create evo_crm_dashboard_controller ./evo-ai-crm-community/app/controllers/dashboard_controller.rb
docker config create evo_crm_inboxes_controller ./evo-ai-crm-community/app/controllers/api/v1/inboxes_controller.rb
docker config create evo_crm_evolution_go_service ./evo-ai-crm-community/app/services/whatsapp/providers/evolution_go_service.rb
```

## Deploy da Stack no Portainer

### 1. Variáveis de ambiente

Na tela de criação da stack, configure as variáveis obrigatórias:

| Variável | Descrição |
|---|---|
| `API_DOMAIN` | Domínio do backend (ex: `api.exemplo.com`) |
| `FRONTEND_DOMAIN` | Domínio do frontend (ex: `app.exemplo.com`) |
| `EVOFLOW_DOMAIN` | Domínio do evo-flow (ex: `flow.exemplo.com`) |
| `SECRET_KEY_BASE` | Chave mestra Rails (mín 64 chars) |
| `JWT_SECRET_KEY` | Chave JWT |
| `DOORKEEPER_JWT_SECRET_KEY` | Chave JWT para doorkeeper |
| `ENCRYPTION_KEY` | Chave de criptografia |
| `BOT_RUNTIME_SECRET` | Secret do bot runtime |
| `POSTGRES_HOST` | Host do PostgreSQL |
| `POSTGRES_PORT` | Porta (default: `5432`) |
| `POSTGRES_USERNAME` | Usuário do PostgreSQL |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL |
| `POSTGRES_DATABASE` | Banco (default: `evo_community`) |
| `POSTGRES_SSLMODE` | SSL mode (default: `require`) |
| `REDIS_URL` | URL completa do Redis (`redis://:senha@redis:6379`) |
| `EVOAI_CRM_API_TOKEN` | Token da API CRM |
| `OAUTH_REDIRECT_URI` | URI de redirecionamento OAuth |

### 2. Variáveis específicas do Processor

| Variável | Descrição |
|---|---|
| `PROCESSOR_POSTGRES_CONNECTION_STRING` | Connection string PostgreSQL |
| `PROCESSOR_REDIS_HOST` | Host Redis |
| `PROCESSOR_REDIS_PORT` | Porta Redis (default: `6379`) |
| `PROCESSOR_REDIS_PASSWORD` | Senha Redis |
| `PROCESSOR_REDIS_DB` | DB Redis (default: `0`) |

### 3. Variáveis específicas do ClickHouse / EvoFlow

| Variável | Descrição |
|---|---|
| `CLICKHOUSE_USER` | Usuário ClickHouse (default: `evoflow`) |
| `CLICKHOUSE_PASSWORD` | Senha ClickHouse |
| `CLICKHOUSE_DB` | DB ClickHouse (default: `evo_flow`) |
| `EVOFLOW_DB` | DB PostgreSQL para evo-flow (default: `evo_community`) |

### 4. Variáveis SMTP (opcional)

| Variável | Descrição |
|---|---|
| `SMTP_ADDRESS` | Endereço do servidor SMTP |
| `SMTP_PORT` | Porta SMTP (default: `587`) |
| `SMTP_USERNAME` | Usuário SMTP |
| `SMTP_PASSWORD` | Senha SMTP |
| `SMTP_DOMAIN` | Domínio SMTP |

### 5. Passos finais

1. Acesse **Stacks → Add stack**
2. Nome: `evo_crm`
3. Build method: **Web Editor**
4. Cole o conteúdo do arquivo `.github/infra/prod-swarm.evo.yaml`
5. Preencha as variáveis de ambiente
6. Clique **Deploy the stack**

### 6. Verificar

- **Services** — confira se todos os 11 serviços estão `running` (1/1 replicas)
- **evo_auth** e **evo_crm** podem demorar mais no primeiro deploy por conta das migrations e seeds
- Os logs de cada serviço podem ser vistos em **Services → [serviço] → Logs**

## Traefik (Pré-requisito)

A stack presume que o **Traefik** já está rodando no Swarm com:
- Network `interna` conectada
- Entrypoint `websecure` (porta 443)
- Certificate resolver `letsencryptresolver` configurado

Se ainda não tem o Traefik, suba-o como uma stack separada antes desta.
