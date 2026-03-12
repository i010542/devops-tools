#!/usr/bin/env bash
# deploy.sh — Zero-downtime deployment via docker compose
set -euo pipefail

SSH_HOST="${1:?Usage: deploy.sh <ssh_host>}"
APP_DIR="${2:-/opt/app}"
COMPOSE_FILE="${3:-docker-compose.yml}"

echo "Deploying to $SSH_HOST:$APP_DIR..."

ssh "$SSH_HOST" bash -s << REMOTE
  set -euo pipefail
  cd "$APP_DIR"
  git pull --ff-only
  docker compose -f "$COMPOSE_FILE" pull
  docker compose -f "$COMPOSE_FILE" up -d --remove-orphans
  docker compose -f "$COMPOSE_FILE" exec app python manage.py migrate --noinput 2>/dev/null || true
  docker image prune -f
  echo "Deployment complete."
REMOTE

echo "Done. Service is up at $SSH_HOST"
