# Evo CRM Community — Guia de Deploy em Docker Swarm

> Gerado em 07/05/2026 com base nos erros e correções identificados na instalação de referência (`swdev`).  
> Siga cada etapa na ordem indicada para evitar os problemas documentados na seção [Erros conhecidos](#erros-conhecidos).

---

## Pré-requisitos

| Componente | Versão mínima | Observação |
|---|---|---|
| Docker Engine | 26+ | Testado com 29.4.3 |
| Docker Swarm | inicializado | `docker swarm init` |
| PostgreSQL | 15+ (pgvector) | Pode ser externo ou em outro stack |
| Redis | 7+ | Pode ser externo ou em outro stack |
| Traefik | v2.x | Deve estar rodando antes do deploy |

---

## 1. Redes overlay

As redes devem existir **antes** do deploy. Crie-as uma única vez:

```bash
docker network create --driver overlay --attachable externa
docker network create --driver overlay --attachable interna
```

> **Regra:** Traefik só descobre os serviços que estão na rede `externa`. Todos os serviços desta stack devem estar em `externa` **e** `interna`. Não use nomes diferentes sem ajustar `--providers.docker.network` no Traefik.

---

## 2. Traefik

O Traefik deve estar rodando em Swarm Mode com os seguintes argumentos obrigatórios:

```
--providers.docker=true
--providers.docker.swarmMode=true
--providers.docker.network=externa
--providers.docker.exposedbydefault=false
--entrypoints.web.address=:80
--entrypoints.web.http.redirections.entryPoint.to=websecure
--entrypoints.web.http.redirections.entryPoint.scheme=https
--entrypoints.websecure.address=:443
--certificatesresolvers.le.acme.email=SEU@EMAIL.COM
--certificatesresolvers.le.acme.httpchallenge.entrypoint=web
--certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
```

### ⚠️ Nome do certresolver

O nome do certresolver configurado acima é `le`. As labels do YAML desta stack já usam `le`. **Nunca use nomes diferentes** (`letsencrypt`, `letsencryptresolver`, etc.) sem editar todas as labels nos serviços `evo_gateway` e `evo_frontend`.

Verificar o nome real em produção:

```bash
docker service inspect traefik_traefik --format '{{range .Spec.TaskTemplate.ContainerSpec.Args}}{{.}} {{end}}' \
  | tr ' ' '\n' | grep certificatesresolvers
```

---

## 3. Preparar o `.env`

Copie o exemplo e preencha **todos** os valores:

```bash
cp .env.swarm.example .env
```

### Gerar os segredos

```bash
# SECRET_KEY_BASE, JWT_SECRET_KEY, DOORKEEPER_JWT_SECRET_KEY (128 hex chars cada)
openssl rand -hex 64

# EVOAI_CRM_API_TOKEN, BOT_RUNTIME_SECRET (64 hex chars cada)
openssl rand -hex 32

# ENCRYPTION_KEY (Fernet key)
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

### Variáveis críticas

```dotenv
# Domínios públicos (sem https://, sem barra final)
API_DOMAIN=api.seudominio.com
FRONTEND_DOMAIN=app.seudominio.com

# Banco de dados
POSTGRES_HOST=nome-do-container-ou-host-postgres
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=SUA_SENHA_AQUI
POSTGRES_DATABASE=evo_com

# ⚠️ SSLMODE: sem aspas. Valores: disable | require | verify-full
POSTGRES_SSLMODE=disable

# Redis (usar nome do serviço Docker, não localhost)
REDIS_URL=redis://redis:6379/1
PROCESSOR_REDIS_HOST=redis
PROCESSOR_REDIS_PORT=6379
PROCESSOR_REDIS_DB=1

# Processor — connection string completa (sem placeholders)
PROCESSOR_POSTGRES_CONNECTION_STRING=postgresql://postgres:SUA_SENHA@nome-postgres:5432/evo_com?sslmode=disable
```

### ❌ Erros comuns no `.env`

| Erro | Causa | Correto |
|---|---|---|
| `POSTGRES_SSLMODE="disable"` | Aspas são parte do valor | `POSTGRES_SSLMODE=disable` |
| `PROCESSOR_POSTGRES_CONNECTION_STRING=postgresql://postgres:CHANGE_ME@your-postgres-host/...` | Placeholder não substituído | Substituir com host e senha reais |
| `REDIS_URL=redis://localhost:6379/1` | `localhost` não resolve entre containers | Usar nome do serviço Docker: `redis://redis:6379/1` |

---

## 4. Docker Config para o model ausente

A imagem `evo-auth-service-community` referencia `SetupSurveyResponse` no User model, mas **não inclui o arquivo do model nem a migration**. Isso causa `NameError` no login com HTTP 500.

Execute **antes do primeiro deploy**:

### 4a. Criar a tabela no banco

```bash
# Substitua o ID pelo container auth após o primeiro up (pode subir sem o config, criar tabela, depois fazer update)
AUTHC=$(docker ps -q --filter "label=com.docker.swarm.service.name=evocrm_evo_auth")
docker exec $AUTHC bundle exec rails runner "
unless ActiveRecord::Base.connection.table_exists?('setup_survey_responses')
  ActiveRecord::Base.connection.create_table :setup_survey_responses do |t|
    t.bigint :user_id, null: false
    t.jsonb  :responses, default: {}
    t.timestamps
  end
  ActiveRecord::Base.connection.add_index :setup_survey_responses, :user_id, unique: true
  puts 'Tabela criada!'
end
"
```

### 4b. Criar o Docker Config com o model

```bash
echo "class SetupSurveyResponse < ApplicationRecord
  belongs_to :user
end" | docker config create evo_auth_setup_survey_model -
```

> O YAML já referencia este config. Ele é montado em `/rails/app/models/setup_survey_response.rb` nos serviços `evo_auth` e `evo_auth_sidekiq`.

---

## 5. Deploy

### ⚠️ Regra fundamental: sempre carregar o `.env` antes de deployar

`docker stack deploy` **NÃO lê `.env` automaticamente**. Se não exportar as variáveis, todos os `${VAR}` viram string vazia — `SECRET_KEY_BASE` vazio derruba o Rails imediatamente.

**Comando correto (use sempre):**

```bash
cd /root/docker/evo-crm-community
set -a && source .env && set +a
docker stack deploy -c docker.swarm.evo.yaml evocrm --with-registry-auth
```

Ou em uma linha:

```bash
cd /root/docker/evo-crm-community && set -a && source .env && set +a && \
  docker stack deploy -c docker.swarm.evo.yaml evocrm --with-registry-auth
```

---

## 6. Verificar convergência

Após o deploy, aguarde ~60 segundos e verifique:

```bash
watch -n5 'docker service ls | grep evocrm | awk '"'"'{print $2, $4}'"'"''
```

Resultado esperado (9/9 em `1/1`):

```
evocrm_evo_auth          1/1
evocrm_evo_auth_sidekiq  1/1
evocrm_evo_bot_runtime   1/1
evocrm_evo_core          1/1
evocrm_evo_crm           1/1
evocrm_evo_crm_sidekiq   1/1
evocrm_evo_frontend      1/1
evocrm_evo_gateway       1/1
evocrm_evo_processor     1/1
```

---

## 7. Validação final

```bash
# HTTP e TLS
curl -sk -o /dev/null -w "API HTTP: %{http_code}\n" https://API_DOMAIN/health
curl -sk -o /dev/null -w "Frontend HTTP: %{http_code}\n" https://FRONTEND_DOMAIN

# Certificado TLS (deve ser Let's Encrypt, não TRAEFIK DEFAULT CERT)
echo | openssl s_client -connect API_DOMAIN:443 -servername API_DOMAIN 2>/dev/null \
  | openssl x509 -noout -subject -issuer

# Login
curl -sk -X POST https://API_DOMAIN/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"SEU_EMAIL","password":"SUA_SENHA"}' | python3 -m json.tool | head -10
```

---

## 8. Resetar senha de usuário

```bash
AUTHC=$(docker ps -q --filter "label=com.docker.swarm.service.name=evocrm_evo_auth")

# Ver qual usuário existe
docker exec $AUTHC bundle exec rails runner "puts User.pluck(:email)" 2>/dev/null | tail -5

# Resetar senha
docker exec $AUTHC bundle exec rails runner "
u = User.find_by(email: 'SEU@EMAIL.COM')
u.password = 'NovaSenha123!'
u.password_confirmation = 'NovaSenha123!'
u.save!
puts 'OK'
" 2>/dev/null | tail -3
```

---

## Erros conhecidos

### E1 — Variáveis vazias no deploy

**Sintoma:** `ArgumentError: secret_key_base for production environment must be a type of String`; serviços sobem mas caem imediatamente.  
**Causa:** `docker stack deploy` não carrega `.env` automaticamente.  
**Fix:** Sempre usar `set -a && source .env && set +a` antes do deploy.

---

### E2 — `node.hostname == manager1` no placement

**Sintoma:** Serviço fica em `0/1` para sempre, sem erros nos logs.  
**Causa:** O YAML original usava hostname hardcoded `manager1`; o nó real tem outro nome.  
**Fix:** Substituir por `node.role == manager` no placement constraint de todos os serviços.

---

### E3 — `POSTGRES_SSLMODE` com aspas

**Sintoma:** Erro de conexão SSL ao banco.  
**Causa:** `POSTGRES_SSLMODE="disable"` — as aspas viram parte do valor.  
**Fix:** `POSTGRES_SSLMODE=disable` (sem aspas).

---

### E4 — `PROCESSOR_POSTGRES_CONNECTION_STRING` com placeholder

**Sintoma:** `evo_processor` não conecta ao banco.  
**Causa:** O exemplo usa `CHANGE_ME@your-postgres-host` e o instalador não percebe.  
**Fix:** Preencher com `postgresql://USER:SENHA@HOST:5432/DB?sslmode=disable`.

---

### E5 — `evo_crm_sidekiq` sem `BACKEND_URL` / `FRONTEND_URL`

**Sintoma:** `evo_crm_sidekiq` crashea em loop com `BACKEND_URL must be set to a public URL in production (got: "")`.  
**Causa:** O serviço `evo_crm` tinha as variáveis mas o `evo_crm_sidekiq` não.  
**Fix:** Adicionar ao environment do `evo_crm_sidekiq`:
```yaml
BACKEND_URL: https://${API_DOMAIN}
FRONTEND_URL: https://${FRONTEND_DOMAIN}
```

---

### E6 — `evo_auth_sidekiq` nunca alcança `1/1` (healthcheck inválido)

**Sintoma:** Container sobe, Sidekiq roda normalmente nos logs, mas o serviço mostra `0/1`.  
**Causa:** A imagem tem `HEALTHCHECK curl localhost:3001` (válido para o web server). O Sidekiq não expõe porta HTTP, então o healthcheck falha sempre.  
**Fix:** No YAML do `evo_auth_sidekiq`:
```yaml
healthcheck:
  disable: true
```

---

### E7 — Login retorna HTTP 500 (`NameError: Missing model SetupSurveyResponse`)

**Sintoma:** Login falha com 500. Log do auth: `NameError - Missing model class SetupSurveyResponse for the User#setup_survey_response association`.  
**Causa:** O `User` model referencia `has_one :setup_survey_response` mas a imagem não inclui o arquivo do model nem a migration.  
**Fix:** Ver [seção 4](#4-docker-config-para-o-model-ausente) — criar tabela no banco + Docker Config montado via YAML.

---

### E8 — TLS mostra "TRAEFIK DEFAULT CERT" em vez de Let's Encrypt

**Sintoma:** `openssl s_client` mostra `CN=TRAEFIK DEFAULT CERT`.  
**Causa:** Labels de serviços anteriores usavam `certresolver=letsencryptresolver` (nome errado para o certresolver `le` configurado no Traefik).  
**Fix:** Garantir que as labels usem o nome exato do certresolver: `tls.certresolver=le`. Verificar com:
```bash
docker service inspect traefik_traefik --format '{{range .Spec.TaskTemplate.ContainerSpec.Args}}{{.}} {{end}}' \
  | tr ' ' '\n' | grep certificatesresolvers
```
