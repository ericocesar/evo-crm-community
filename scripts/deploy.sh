#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== Loading .env ==="
set -a; source .env; set +a

echo "=== Deploying stack: evocrm ==="
docker stack deploy --resolve-image never -c docker.swarm.evo.yaml evocrm

echo "=== Done ==="
