pnpm push:auth → Builda e faz push do serviço de autenticação.
pnpm push:core → Builda e faz push do serviço core.
pnpm push:bot-runtime → Builda e faz push do bot runtime.
pnpm push:gateway → Builda e faz push do gateway Nginx.
pnpm push:everything → Executa o build e push sequencial de todos os 8 serviços do monorepo para o seu GHCR.

pnpm git "commit message" commita e push em todos os repos.

# Clonar
Para clonar o repositório principal trazendo todos os submódulos de forma automática em um único comando, execute:
git clone --recurse-submodules https://github.com/ericocesar/evo-crm-community.git


*(Caso o Git no servidor seja mais antigo, você pode usar `--recursive` em vez de `--recurse-submodules`):*
```bash
git clone --recursive https://github.com/ericocesar/evo-crm-community.git
```

---

### Se você já clonou o repositório sem os submódulos
Se o clone já foi feito apenas com a pasta raiz, você pode baixar e inicializar todos os submódulos rodando o seguinte comando de dentro da pasta do projeto:

```bash
git submodule update --init --recursive
```


# Se alterou a imagem do evo-crm e do evo-auth, o container de Auth rodará as migrations dele automaticamente.
# rodar manualmente migrate evo_crm
bundle exec rails db:migrate

# init local
docker compose -f docker-compose.yml up -d

Ou use o atalho do Makefile:
make start
Que executa docker compose up -d. 

Para rebuildar as imagens primeiro:
make build    # rebuild all images sem cache
make start    # start services

Se for a primeira vez, rode também:
make seed     # CRM schema primeiro, depois auth





set -a; source .env; set +a
docker stack deploy --resolve-image never -c docker.swarm.evo.yaml evocrm

AUTH=$(docker ps -q --filter label=com.docker.swarm.service.name=evocrm_evo_auth) 
CRM=$(docker ps -q --filter label=com.docker.swarm.service.name=evocrm_evo_crm)


docker exec -it "$AUTH" bundle exec rails db:create db:migrate RAILS_ENV=development

# crm
docker exec -it "$CRM" bin/rails db:environment:set RAILS_ENV=development

# Atualizar pelo upstream da evorcrm

git status
git stash push -m "backup antes de atualizar upstream"

git fetch upstream
git checkout main
git merge upstream/main
git push origin main

git stash pop