---
type: doc
name: tooling
description: Scripts, IDE settings, automation, and developer productivity tips
category: tooling
generated: 2026-05-28
status: filled
scaffoldVersion: "2.0.0"
---

## Tooling & Productivity Guide

This document covers the tools, scripts, and automation available to Evo CRM Community developers.

## Required Tooling

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| **Docker Desktop** | 24+ | Container runtime for all services | https://docs.docker.com/desktop/ |
| **Git** | 2.40+ | Version control with submodule support | `brew install git` (macOS) |
| **Docker Compose** | v2+ | Multi-container orchestration | Bundled with Docker Desktop |
| **Make** | 3.81+ | Build automation (Makefile targets) | Bundled with macOS / `apt install make` |
| **Ruby** | 3.4+ | Local development for Rails services | `brew install ruby` or `rbenv` |
| **Node.js** | 20+ | Frontend and evo-flow development | `brew install node` or `nvm` |
| **Python** | 3.10+ | Processor service development | `brew install python` or `pyenv` |
| **Go** | 1.21+ | Core and bot-runtime development | `brew install go` |

## Recommended Automation

### Makefile Targets

The root `Makefile` provides 20+ targets for common workflows:

```bash
make help          # Show all available targets
make setup         # Full first-time setup (init submodules, build, start, seed)
make start         # Start all services
make stop          # Stop all services
make restart       # Stop + start
make build         # Rebuild all images (no cache)
make status        # Show service health
make logs          # View all logs
make logs SERVICE=crm  # View specific service logs
make seed          # Run all seeds (CRM first, then auth)
make seed-crm      # Seed CRM only
make seed-auth     # Seed auth only
make shell-crm     # Bash shell in CRM container
make shell-auth    # Bash shell in auth container
make shell-core    # Shell in core container
make shell-processor # Bash in processor container
make shell-bot-runtime # Shell in bot-runtime container
make clean         # Stop and remove volumes
```

### Build Scripts

```bash
# Build and push all images to GHCR
./scripts/build-push.sh

# Build frontend image locally
./scripts/buildfront.sh

# Deploy to Docker Swarm
./scripts/deploy.sh
```

### Setup Script

```bash
# Interactive first-time setup
./setup.sh
# Copies .env.example → .env, initializes submodules, builds, starts, seeds
```

### Pre-Commit Checks

Before committing, run:
```bash
# Validate Docker Compose configs
docker compose -f docker-compose.yml config
docker compose -f docker-compose.swarm.yaml config

# Lint Dockerfiles (matching CI)
docker run --rm -i hadolint/hadolint < nginx/Dockerfile

# Check submodule status
git submodule status

# Verify commit messages follow Conventional Commits
git log --oneline -10
```

## IDE / Editor Setup

### VS Code (Recommended)

Essential extensions:
- **Docker** (ms-azuretools.vscode-docker) — Docker Compose syntax highlighting and IntelliSense
- **Ruby** (rebornix.ruby) — Ruby language support with debugging
- **Python** (ms-python.python) — Python language support
- **Go** (golang.go) — Go language support
- **ESLint** (dbaeumer.vscode-eslint) — JavaScript/TypeScript linting
- **Prettier** (esbenp.prettier-vscode) — Code formatting
- **DotENV** (mikestead.dotenv) — .env file syntax highlighting

### JetBrains IntelliJ / RubyMine

- Built-in support for Ruby, Rails, Docker, Git submodules
- Configure Docker Compose as a run configuration for integrated debugging
- Database tool window: connect to PostgreSQL on `localhost:5432`

## Productivity Tips

### Quick Access Aliases

Add to `.bashrc` / `.zshrc`:
```bash
alias evo-up='make start'
alias evo-down='make stop'
alias evo-logs='make logs'
alias evo-crm='make shell-crm'
alias evo-auth='make shell-auth'
alias evo-rebuild='make build && make start'
```

### Docker Commands

```bash
# View logs for a specific service with follow
docker compose logs -f crm

# Restart a single service
docker compose restart processor

# Rebuild a single service
docker compose build --no-cache crm

# Access PostgreSQL directly
docker compose exec postgres psql -U postgres -d evo_community

# Access Redis CLI
docker compose exec redis redis-cli
```

### Submodule Workflow

```bash
# Update all submodules to latest remote commits
git submodule update --remote

# Work inside a submodule
cd evo-ai-crm-community
git checkout -b feat/my-feature
# ... make changes, commit, push ...
cd ..
git add evo-ai-crm-community
git commit -m "chore: update crm submodule pin"

# Initialize submodules after fresh clone
git submodule update --init --recursive
```

### Database Management

```bash
# Run migrations inside CRM container
docker compose exec crm bundle exec rails db:migrate

# Run migrations inside auth container
docker compose exec auth bundle exec rails db:migrate

# Reset database
make clean && make start && make seed
```

### API Testing

```bash
# Test auth endpoints
curl http://localhost:3030/api/v1/auth/login -H "Content-Type: application/json" -d '{"email":"admin@example.com","password":"password"}'

# Test CRM endpoints with token
curl http://localhost:3030/api/v1/accounts -H "Authorization: Bearer <token>"

# Test agent endpoints
curl http://localhost:3030/api/v1/agents -H "Authorization: Bearer <token>"

# Health checks
curl http://localhost:3030/health
curl http://localhost:3030/ready
```
