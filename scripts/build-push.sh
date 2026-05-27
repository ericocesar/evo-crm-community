#!/usr/bin/env bash
set -euo pipefail

# Build e Push para GitHub Container Registry (ghcr.io)
#
# Uso:
#   GHCR_TOKEN=<PAT> ./scripts/build-push.sh [--no-cache] [--frontend-only] [--flow-only]
#
# Imagens geradas:
#   ghcr.io/ericocesar/evo-crm-community-frontend:<branch>
#   ghcr.io/ericocesar/evo-crm-community-frontend:sha-<7chars>
#   ghcr.io/ericocesar/evo-crm-community-flow:<branch>
#   ghcr.io/ericocesar/evo-crm-community-flow:sha-<7chars>
#
# Também mantém a tag local para uso no Docker Swarm:
#   local/evo-frontend:custom
#
# Flags:
#   --no-cache       Build SEM cache do Docker
#   --frontend-only  Builda e faz push apenas do frontend
#   --flow-only      Builda e faz push apenas do evo-flow
#
# Requisitos:
#   - Docker daemon rodando
#   - GHCR_TOKEN exportado (Personal Access Token com escopo packages:write)
#     export GHCR_TOKEN=ghp_xxx
#   - Ou já autenticado: echo "$GHCR_TOKEN" | docker login ghcr.io -u ericocesar --password-stdin

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
REGISTRY="ghcr.io"
NAMESPACE="ericocesar"
IMAGE_FRONTEND="${REGISTRY}/${NAMESPACE}/evo-crm-community-frontend"
IMAGE_FLOW="${REGISTRY}/${NAMESPACE}/evo-crm-community-flow"
LOCAL_FRONTEND_TAG="local/evo-frontend:custom"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------
NO_CACHE=false
BUILD_FRONTEND=true
BUILD_FLOW=true

for arg in "$@"; do
  case "${arg}" in
    --no-cache)       NO_CACHE=true ;;
    --frontend-only)  BUILD_FLOW=false ;;
    --flow-only)      BUILD_FRONTEND=false ;;
  esac
done

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------
GIT_SHA_SHORT="$(git rev-parse --short=7 HEAD)"
BRANCH="$(git rev-parse --abbrev-ref HEAD | tr '[:upper:]' '[:lower:]' | tr '/' '-')"
TAG_SHA="sha-${GIT_SHA_SHORT}"
TAG_BRANCH="${BRANCH}"

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo "============================================="
echo "  Build e Push Docker → GHCR"
echo "============================================="
echo "Registry:   ${REGISTRY}"
echo "Namespace:  ${NAMESPACE}"
echo "Branch:     ${BRANCH}"
echo "Tags:       ${TAG_BRANCH}, ${TAG_SHA}"
if [ "${NO_CACHE}" = true ]; then
  echo "Cache:      DESABILITADO (--no-cache)"
else
  echo "Cache:      habilitado"
fi
echo ""
if [ "${BUILD_FRONTEND}" = true ]; then
  echo "  Frontend:  ${IMAGE_FRONTEND}:${TAG_SHA}"
fi
if [ "${BUILD_FLOW}" = true ]; then
  echo "  Evo-flow:  ${IMAGE_FLOW}:${TAG_SHA}"
fi
echo "============================================="

# ---------------------------------------------------------------------------
# 0. Commit e push das alterações pendentes
# ---------------------------------------------------------------------------
echo ""
echo ">>> [0/3] Verificando status do Git..."

if git diff --quiet && git diff --cached --quiet; then
  echo "    ✓ Sem alterações pendentes."
else
  echo "    → Commitando alterações..."
  git add -A
  git commit -m "chore: build ${TAG_SHA}" || true

  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  echo "    → Push para origin/${CURRENT_BRANCH}..."
  git push origin "${CURRENT_BRANCH}" 2>&1 || echo "    ⚠️  Push falhou (verifique permissões do remote)."

  # Atualiza sha após commit
  GIT_SHA_SHORT="$(git rev-parse --short=7 HEAD)"
  TAG_SHA="sha-${GIT_SHA_SHORT}"
  echo "    ✓ Tag atualizada para: ${TAG_SHA}"
fi

# ---------------------------------------------------------------------------
# 1. Verificação de segurança com Trivy (opcional)
# ---------------------------------------------------------------------------
echo ""
echo ">>> [1/3] Verificação de segurança com Trivy..."

if ! command -v trivy &> /dev/null; then
  echo "    ⚠️  Trivy não encontrado — pulando varredura."
  echo "       Para instalar: apt-get install trivy  ou  brew install trivy"
else
  TRIVY_EXIT_CODE=0
  trivy fs \
    --scanners misconfig,vuln \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    --skip-version-check \
    --ignorefile "${ROOT_DIR}/.trivyignore" \
    "${ROOT_DIR}" || TRIVY_EXIT_CODE=$?

  if [[ "${TRIVY_EXIT_CODE}" -ne 0 ]]; then
    echo ""
    echo "  ❌ Trivy encontrou vulnerabilidades HIGH/CRITICAL. Abortando."
    echo "     Execute para detalhes:"
    echo "     trivy fs --scanners misconfig,vuln --severity HIGH,CRITICAL ."
    exit 1
  fi
  echo "    ✓ Nenhuma vulnerabilidade HIGH/CRITICAL encontrada."
fi

# ---------------------------------------------------------------------------
# 2. Login no GHCR
# ---------------------------------------------------------------------------
echo ""
echo ">>> [2/3] Autenticação no ${REGISTRY}..."

if ! docker system info > /dev/null 2>&1; then
  echo "  ❌ Docker daemon não está rodando."
  exit 1
fi

# Tenta reutilizar credenciais existentes; se falhar, exige GHCR_TOKEN
if docker login "${REGISTRY}" --username "${NAMESPACE}" --password-stdin <<< "" > /dev/null 2>&1; then
  echo "    ✓ Já autenticado no ${REGISTRY}."
elif [[ -n "${GHCR_TOKEN:-}" ]]; then
  echo "    → Fazendo login com GHCR_TOKEN..."
  echo "${GHCR_TOKEN}" | docker login "${REGISTRY}" -u "${NAMESPACE}" --password-stdin
  echo "    ✓ Login realizado."
else
  echo "  ❌ Não autenticado no ${REGISTRY} e GHCR_TOKEN não definido."
  echo ""
  echo "  Exporte seu Personal Access Token (escopo: packages:write):"
  echo "    export GHCR_TOKEN=ghp_xxxxxxxxxxxxxxxxxx"
  echo "    ./scripts/build-push.sh"
  exit 1
fi

# ---------------------------------------------------------------------------
# 3. Build e Push
# ---------------------------------------------------------------------------
echo ""
echo ">>> [3/3] Build e Push das imagens..."

BUILD_ARGS=""
if [ "${NO_CACHE}" = true ]; then
  BUILD_ARGS="--no-cache"
  echo "    🚫 Cache desabilitado"
fi

# ---- Frontend ---------------------------------------------------------------
if [ "${BUILD_FRONTEND}" = true ]; then
  echo ""
  echo "  → [frontend] Contexto: ./evo-ai-frontend-community"

  # shellcheck disable=SC2086
  docker build \
    ${BUILD_ARGS} \
    -t "${IMAGE_FRONTEND}:${TAG_BRANCH}" \
    -t "${IMAGE_FRONTEND}:${TAG_SHA}" \
    -t "${LOCAL_FRONTEND_TAG}" \
    ./evo-ai-frontend-community

  docker push "${IMAGE_FRONTEND}:${TAG_BRANCH}"
  docker push "${IMAGE_FRONTEND}:${TAG_SHA}"

  echo "    ✓ Frontend enviado:"
  echo "      ${IMAGE_FRONTEND}:${TAG_BRANCH}"
  echo "      ${IMAGE_FRONTEND}:${TAG_SHA}"
  echo "    ✓ Tag local mantida: ${LOCAL_FRONTEND_TAG}"
fi

# ---- Evo-flow ---------------------------------------------------------------
if [ "${BUILD_FLOW}" = true ]; then
  echo ""
  echo "  → [evo-flow] Contexto: ./evo-flow"

  # shellcheck disable=SC2086
  docker build \
    ${BUILD_ARGS} \
    -t "${IMAGE_FLOW}:${TAG_BRANCH}" \
    -t "${IMAGE_FLOW}:${TAG_SHA}" \
    ./evo-flow

  docker push "${IMAGE_FLOW}:${TAG_BRANCH}"
  docker push "${IMAGE_FLOW}:${TAG_SHA}"

  echo "    ✓ Evo-flow enviado:"
  echo "      ${IMAGE_FLOW}:${TAG_BRANCH}"
  echo "      ${IMAGE_FLOW}:${TAG_SHA}"
fi

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
echo ""
echo "============================================="
echo "  ✅ Build e Push concluídos!"
echo "============================================="
echo ""
echo "Imagens no GHCR (https://ghcr.io/${NAMESPACE}):"
echo ""
if [ "${BUILD_FRONTEND}" = true ]; then
  echo "  Frontend:"
  echo "    ${IMAGE_FRONTEND}:${TAG_BRANCH}"
  echo "    ${IMAGE_FRONTEND}:${TAG_SHA}"
  echo ""
fi
if [ "${BUILD_FLOW}" = true ]; then
  echo "  Evo-flow:"
  echo "    ${IMAGE_FLOW}:${TAG_BRANCH}"
  echo "    ${IMAGE_FLOW}:${TAG_SHA}"
  echo ""
fi
echo "  Tag local para Swarm:"
echo "    ${LOCAL_FRONTEND_TAG}"
echo ""
echo "  Para atualizar o serviço em produção:"
echo "    docker service update --force evocrm_evo_frontend"
echo "============================================="
