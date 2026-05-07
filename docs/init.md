docker stack deploy -c docker.swarm.evo.yaml evo


AUTH=$(docker ps -q --filter label=com.docker.swarm.service.name=evocrm_evo_auth) 
CRM=$(docker ps -q --filter label=com.docker.swarm.service.name=evocrm_evo_crm)

echo "AUTH=$AUTH"
echo "CRM=$CRM"
AUTH=35b55daf207d
CRM=cf5dc29ef164
root@swdev:~/docker/evo-crm-community# docker ps \
  --filter label=com.docker.swarm.service.name=evocrm_evo_auth \
  --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'

docker ps \
  --filter label=com.docker.swarm.service.name=evocrm_evo_crm \
  --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
CONTAINER ID   NAMES                                         STATUS
35b55daf207d   evocrm_evo_auth.1.qbl24qrv9eadduiedm9hpgehk   Up About an hour (healthy)
CONTAINER ID   NAMES                                        STATUS
cf5dc29ef164   evocrm_evo_crm.1.jgp6j5y3cf37g09wdf9izr0zn   Up About an hour

docker exec -it "$AUTH" bundle exec rails db:create db:migrate RAILS_ENV=development

# crm
docker exec -it "$CRM" bin/rails db:environment:set RAILS_ENV=development

git config --global user.email "ericocesar@webck.com.br"
git config --global user.name "ericocesar"