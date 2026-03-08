#!/bin/bash
set -e

NAME=${1:-""}
PORT=${2:-""}
GIT_REPO=${3:-""}
GIT_BRANCH=${4:-"main"}

if [ -z "$NAME" ]; then
  echo "Usage: $0 <nom> [port] [git-repo-url] [branche]"
  echo "Exemple: $0 mon-api 3002 https://github.com/moi/mon-api.git main"
  exit 1
fi

PROJECTS_DIR="$(dirname "$0")/../projects"

if [ -d "$PROJECTS_DIR/$NAME" ]; then
  echo "❌ Le projet '$NAME' existe déjà."
  exit 1
fi

# Port auto si non fourni
if [ -z "$PORT" ]; then
  LAST_PORT=$(find "$PROJECTS_DIR" -name "docker-compose.yml" \
    | xargs grep -h "3[0-9][0-9][0-9]:3[0-9][0-9][0-9]" 2>/dev/null \
    | grep -o "3[0-9][0-9][0-9]" | sort -n | tail -1)
  PORT=$(( ${LAST_PORT:-3000} + 1 ))
fi

UPPER_NAME=$(echo "$NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

echo "📦 Création du projet '$NAME' sur le port $PORT..."

mkdir -p "$PROJECTS_DIR/$NAME"

# Dockerfile
cat > "$PROJECTS_DIR/$NAME/Dockerfile" << DFEOF
FROM node:22-slim

RUN apt-get update && apt-get install -y \\
    git curl bash openssh-server vim \\
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd \\
    && useradd -m -s /bin/bash dev \\
    && echo "dev:dev" | chpasswd \\
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN npm install -g @anthropic-ai/claude-code
RUN claude --version || true

RUN mkdir -p /app/src
WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE $PORT 22
ENTRYPOINT ["/entrypoint.sh"]
DFEOF

# entrypoint.sh
cat > "$PROJECTS_DIR/$NAME/entrypoint.sh" << 'EOFE'
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
  echo "🚀 Démarrage..."
  cd "$APP_DIR"
  npm start 2>/dev/null || node index.js 2>/dev/null || tail -f /dev/null
else
  echo "✅ Container prêt — utilise cdev code pour travailler."
  tail -f /dev/null
fi
EOFE
chmod +x "$PROJECTS_DIR/$NAME/entrypoint.sh"

# docker-compose.yml
cat > "$PROJECTS_DIR/$NAME/docker-compose.yml" << DCEOF
services:
  $NAME:
    build: .
    container_name: $NAME
    environment:
      - GIT_REPO=\${${UPPER_NAME}_REPO:-$GIT_REPO}
      - GIT_BRANCH=\${${UPPER_NAME}_BRANCH:-$GIT_BRANCH}
      - DATABASE_URL=postgresql://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@postgres:5432/\${POSTGRES_DB}
      - REDIS_URL=redis://redis:6379
      - PORT=$PORT
    volumes:
      - ${NAME}-code:/app/src
      - \${SSH_KEY_PATH:-~/.ssh}:/root/.ssh:ro
    ports:
      - "$PORT:$PORT"
    networks:
      - claudecode-for-dev_dev-network

volumes:
  ${NAME}-code:

networks:
  claudecode-for-dev_dev-network:
    external: true
DCEOF

echo ""
echo "✅ Projet '$NAME' créé dans projects/$NAME/"
echo ""
echo "Pour le démarrer :"
echo "  cdev up $NAME"
