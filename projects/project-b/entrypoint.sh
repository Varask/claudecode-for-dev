#!/bin/bash
set -e

REPO_URL="${GIT_REPO:-}"
BRANCH="${GIT_BRANCH:-main}"
APP_DIR="/app/src"

if [ -n "$REPO_URL" ]; then
  if [ ! -d "$APP_DIR/.git" ]; then
    echo "📦 Clonage de $REPO_URL (branche: $BRANCH)..."
    git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
    echo "✅ Repo cloné."
  else
    echo "🔄 Repo existant — git pull..."
    cd "$APP_DIR" && git pull origin "$BRANCH"
  fi

  if [ -f "$APP_DIR/package.json" ]; then
    echo "📦 npm install..."
    cd "$APP_DIR" && npm install --silent
  fi
else
  echo "⚠️  GIT_REPO non défini — container prêt sans code."
  mkdir -p "$APP_DIR"
fi

/usr/sbin/sshd

if [ -f "$APP_DIR/package.json" ]; then
  echo "🚀 Démarrage de l'application..."
  cd "$APP_DIR"
  npm start 2>/dev/null || node index.js 2>/dev/null || tail -f /dev/null
else
  echo "✅ Container prêt — utilise 'cdev code project-b' pour travailler."
  tail -f /dev/null
fi
