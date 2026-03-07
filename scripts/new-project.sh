#!/bin/bash
set -e

PROJECT=${1:-""}
PORT=${2:-""}

if [ -z "$PROJECT" ]; then
  echo "Usage: $0 <nom-du-projet> [port]"
  echo "Exemple: $0 project-c 3002"
  exit 1
fi

PROJECTS_DIR="$(dirname "$0")/../projects"

if [ -d "$PROJECTS_DIR/$PROJECT" ]; then
  echo "❌ Le projet '$PROJECT' existe déjà."
  exit 1
fi

# Trouver un port libre si non spécifié
if [ -z "$PORT" ]; then
  LAST_PORT=$(find "$PROJECTS_DIR" -name "docker-compose.yml" \
    | xargs grep -h "3[0-9][0-9][0-9]:3" 2>/dev/null \
    | grep -o "3[0-9][0-9][0-9]" | sort -n | tail -1)
  PORT=$(( ${LAST_PORT:-3000} + 1 ))
fi

echo "📦 Création du projet '$PROJECT' sur le port $PORT..."

mkdir -p "$PROJECTS_DIR/$PROJECT/src"

# Dockerfile
cat > "$PROJECTS_DIR/$PROJECT/Dockerfile" << EOF
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

WORKDIR /app
COPY src/ /app/src/

WORKDIR /app/src
RUN npm install 2>/dev/null || true

EXPOSE $PORT 22
CMD ["/bin/bash", "-c", "/usr/sbin/sshd && node index.js"]
EOF

# docker-compose.yml
cat > "$PROJECTS_DIR/$PROJECT/docker-compose.yml" << EOF
services:
  $PROJECT:
    build: .
    container_name: $PROJECT
    environment:
      - DATABASE_URL=postgresql://user:changeme@postgres:5432/mydb
      - REDIS_URL=redis://redis:6379
      - PORT=$PORT
    volumes:
      - ${PROJECT}-code:/app/src
    ports:
      - "$PORT:$PORT"
    networks:
      - claudecode-for-dev_dev-network

volumes:
  ${PROJECT}-code:

networks:
  claudecode-for-dev_dev-network:
    external: true
EOF

# src/package.json
cat > "$PROJECTS_DIR/$PROJECT/src/package.json" << EOF
{
  "name": "$PROJECT",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "node --watch index.js"
  }
}
EOF

# src/index.js
cat > "$PROJECTS_DIR/$PROJECT/src/index.js" << EOF
const http = require("http");
const PORT = process.env.PORT || $PORT;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ project: "$PROJECT", status: "ok" }));
});

server.listen(PORT, () => {
  console.log(\`$PROJECT running on port \${PORT}\`);
});
EOF

echo ""
echo "✅ Projet '$PROJECT' créé dans projects/$PROJECT/"
echo ""
echo "Pour le démarrer :"
echo "  ./scripts/project.sh start $PROJECT"
echo ""
echo "Pour lancer Claude Code dessus :"
echo "  ./scripts/claude-run.sh $PROJECT \"ton prompt ici\""
