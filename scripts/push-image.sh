#!/usr/bin/env bash
set -euo pipefail

# Helper script to build, tag with both 'latest' and current git branch, and push to GHCR.
# Usage:
#   ./scripts/push-image.sh <docker-compose-service-name> <ghcr-image-url-without-tag>
# Example:
#   ./scripts/push-image.sh evo-crm ghcr.io/ericocesar/evo-ai-crm-community

SERVICE_NAME="$1"
IMAGE_NAME="$2"

BRANCH="$(git rev-parse --abbrev-ref HEAD | tr '[:upper:]' '[:lower:]' | tr '/' '-')"

echo "============================================="
echo "  Building and Pushing Service: ${SERVICE_NAME}"
echo "  Target Image: ${IMAGE_NAME}"
echo "  Branch:       ${BRANCH}"
echo "============================================="

echo ">>> [1/3] Building image..."
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose build "${SERVICE_NAME}"

echo ">>> [2/3] Tagging image with branch '${BRANCH}'..."
docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${BRANCH}"

echo ">>> [3/3] Pushing tags to GHCR..."
echo "  Pushing ${IMAGE_NAME}:latest..."
docker push "${IMAGE_NAME}:latest"

echo "  Pushing ${IMAGE_NAME}:${BRANCH}..."
docker push "${IMAGE_NAME}:${BRANCH}"

echo "============================================="
echo "  ✅ Done pushing ${SERVICE_NAME}!"
echo "============================================="
