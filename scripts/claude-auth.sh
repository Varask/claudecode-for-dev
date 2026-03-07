#!/bin/bash
set -e

echo "🔐 Authentification OAuth Claude Code..."
docker compose run --rm claude-auth
