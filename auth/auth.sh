#!/bin/bash
set -e

echo "╔══════════════════════════════════════╗"
echo "║     Claude Code — Auth OAuth         ║"
echo "╚══════════════════════════════════════╝"
echo ""

TOKEN_FILE="/home/claude/.claude/.credentials.json"

if [ -f "$TOKEN_FILE" ]; then
  echo "✅ Session existante détectée."
  echo "   Veux-tu te ré-authentifier ? (o/N)"
  read -r response
  if [[ ! "$response" =~ ^[oO]$ ]]; then
    echo "→ Utilisation de la session existante."
    exit 0
  fi
fi

echo "🔐 Lancement du flow OAuth claude.ai..."
echo ""

claude auth login

echo ""
echo "✅ Authentification réussie !"
echo "   Token stocké dans le volume 'claude-auth'"
