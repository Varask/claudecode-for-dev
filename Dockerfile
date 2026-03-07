FROM node:22-slim

# Dépendances système
RUN apt-get update && apt-get install -y \
    git curl bash python3 make g++ \
    postgresql-client redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Installer Claude Code globalement
RUN npm install -g @anthropic-ai/claude-code

# Répertoire de travail
WORKDIR /workspace

# Utilisateur non-root pour la sécurité
RUN useradd -m -s /bin/bash claude
RUN chown -R claude:claude /workspace
USER claude

ENTRYPOINT ["claude"]
CMD ["--help"]