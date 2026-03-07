#!/bin/bash
set -e

echo "🚀 Démarrage de l'infra partagée..."

if [ ! -f ".env" ]; then
  echo "⚠️  Fichier .env manquant. Copie depuis .env.example..."
  cp .env.example .env
  echo "→ Édite .env avec tes vraies valeurs, puis relance."
  exit 1
fi

docker compose up -d postgres redis

echo ""
echo "✅ Infra démarrée :"
echo "   • PostgreSQL → localhost:5432"
echo "   • Redis      → localhost:6379"
echo ""
echo "💡 Pour démarrer un projet :"
echo "   ./scripts/project.sh start project-a"
