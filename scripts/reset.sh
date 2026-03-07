#!/bin/bash

echo "⚠️  Ceci va supprimer tous les containers et volumes Docker."
echo "   Continuer ? (o/N)"
read -r response

if [[ "$response" =~ ^[oO]$ ]]; then
  # Arrêter les projets
  for dir in projects/*/; do
    if [ -f "$dir/docker-compose.yml" ]; then
      cd "$dir" && docker compose down -v 2>/dev/null || true && cd ../..
    fi
  done
  # Arrêter l'infra
  docker compose down -v
  echo "✅ Tout supprimé."
else
  echo "→ Annulé."
fi
