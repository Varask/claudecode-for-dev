#!/bin/bash

PROJECT=${1:-""}

# ── Sans projet : liste les containers actifs ─────────────
if [ -z "$PROJECT" ]; then
  echo ""
  echo "Usage: $0 <nom-du-projet>"
  echo ""
  echo "Containers actifs :"
  docker ps --format "  ● {{.Names}}  ({{.Status}})"
  echo ""
  exit 1
fi

# ── Vérifier que le container tourne ──────────────────────
if ! docker ps --format "{{.Names}}" | grep -q "^${PROJECT}$"; then
  echo ""
  echo "❌ Container '$PROJECT' n'est pas en cours d'exécution."
  echo "   Lance-le avec : ./scripts/project.sh start $PROJECT"
  echo ""
  exit 1
fi

# ── Vérifier l'auth ────────────────────────────────────────
VOLUME_NAME=$(docker volume ls --format "{{.Name}}" | grep "claude-auth" | head -1)

AUTHED=$(docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  alpine sh -c "[ -f /data/.credentials.json ] && echo yes || echo no" 2>/dev/null || echo "no")

if [ "$AUTHED" = "no" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
  echo ""
  echo "⚠️  Aucune authentification détectée."
  echo "   Lance d'abord : ./scripts/claude-auth.sh"
  echo ""
  exit 1
fi

# ── Injecter le token OAuth dans le container projet ──────
if [ -n "$VOLUME_NAME" ]; then
  docker run --rm \
    -v "${VOLUME_NAME}:/src" \
    -v "${PROJECT}_home:/dst" \
    alpine sh -c "mkdir -p /dst/.claude && cp -r /src/. /dst/.claude/" 2>/dev/null || true
fi

echo ""
echo "🤖 Claude Code — $PROJECT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   /app/src est le répertoire de travail"
echo "   Ctrl+C ou /exit pour quitter"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Mode interactif complet — TTY direct sur claude ───────
# docker exec sans sh -c pour préserver le TTY complet :
# toutes les fonctionnalités sont disponibles (slash commands,
# vim mode, historique, autocomplétion, multi-turn, etc.)
docker exec \
  --interactive \
  --tty \
  --workdir /app/src \
  --env ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
  --env TERM="${TERM:-xterm-256color}" \
  --env COLORTERM="${COLORTERM:-truecolor}" \
  "$PROJECT" \
  claude
