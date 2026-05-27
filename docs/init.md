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