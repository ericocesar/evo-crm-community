pnpm push             # → ./scripts/build-push.sh
pnpm push:all         # → ./scripts/build-push.sh --processor
pnpm push:processor   # → ./scripts/build-push.sh --processor-only


# No Mac, criar builder multi-plataforma (primeira vez so)
docker buildx create --use --name multiplatform

# Depois rebuild e push
cd /Users/ericocesar/Mac.local/boltdev/2026/BChat/evo-crm-community

docker buildx build --platform linux/amd64 \
  -t ghcr.io/ericocesar/evo-crm-community-frontend:develop \
  -t ghcr.io/ericocesar/evo-crm-community-frontend:sha-$(git rev-parse --short HEAD) \
  --push ./evo-ai-frontend-community

docker buildx build --platform linux/amd64 \
  -t ghcr.io/ericocesar/evo-crm-community-flow:develop \
  -t ghcr.io/ericocesar/evo-crm-community-flow:sha-$(git rev-parse --short HEAD) \
  --push ./evo-flow

docker buildx build --platform linux/amd64 \
  -t ghcr.io/ericocesar/evo-ai-processor-community:latest \
  --push ./evo-ai-processor-community

Depois no servidor:
docker stack deploy -c .github/infra/prod-swarm.evo.yaml crmbchat --with-registry-auth


# build-push.sh builda todos?
Não. Pelos defaults do script:
BUILD_FRONTEND=true
BUILD_FLOW=true
BUILD_PROCESSOR=false   # ← processor OFF por padrão

Rodando sem flags, ele builda/push apenas **frontend** + **evo-flow**, mas **não o processor**.

Para incluir o processor, precisa passar `--processor` ou `--processor-only`:
./scripts/build-push.sh --processor          # frontend + flow + processor
./scripts/build-push.sh --processor-only     # só o processor
