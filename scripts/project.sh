#!/bin/bash
set -e

ACTION=${1:-"list"}
PROJECT=${2:-""}

PROJECTS_DIR="$(dirname "$0")/../projects"

list_projects() {
  echo "📦 Projets disponibles :"
  for dir in "$PROJECTS_DIR"/*/; do
    name=$(basename "$dir")
    running=$(docker ps --filter "name=$name" --format "{{.Names}}" 2>/dev/null)
    if [ -n "$running" ]; then
      echo "   ● $name  [running]"
    else
      echo "   ○ $name  [stopped]"
    fi
  done
}

case "$ACTION" in
  list)
    list_projects
    ;;

  start)
    if [ -z "$PROJECT" ]; then
      echo "Usage: $0 start <nom-du-projet>"
      list_projects
      exit 1
    fi
    if [ ! -d "$PROJECTS_DIR/$PROJECT" ]; then
      echo "❌ Projet '$PROJECT' introuvable dans projects/"
      list_projects
      exit 1
    fi
    echo "🚀 Démarrage de $PROJECT..."
    cd "$PROJECTS_DIR/$PROJECT"
    docker compose up -d --build
    echo "✅ $PROJECT démarré."
    ;;

  stop)
    if [ -z "$PROJECT" ]; then
      echo "Usage: $0 stop <nom-du-projet>"
      exit 1
    fi
    echo "🛑 Arrêt de $PROJECT..."
    cd "$PROJECTS_DIR/$PROJECT"
    docker compose down
    ;;

  logs)
    if [ -z "$PROJECT" ]; then
      echo "Usage: $0 logs <nom-du-projet>"
      exit 1
    fi
    docker logs -f "$PROJECT"
    ;;

  *)
    echo "Usage: $0 [list|start|stop|logs] [nom-du-projet]"
    ;;
esac
