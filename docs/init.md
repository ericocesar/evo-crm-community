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