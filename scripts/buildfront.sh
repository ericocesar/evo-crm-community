#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../evo-ai-frontend-community"

IMAGE_NAME="${1:-evo-frontend-local}"

echo "=== Building frontend image: $IMAGE_NAME ==="
docker build -t "$IMAGE_NAME" -f Dockerfile . --no-cache

echo ""
echo "=== Done! Image $IMAGE_NAME built successfully ==="
