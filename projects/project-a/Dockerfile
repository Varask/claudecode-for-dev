FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git curl bash openssh-server vim \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH
RUN mkdir /var/run/sshd \
    && useradd -m -s /bin/bash dev \
    && echo "dev:dev" | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Claude Code installé globalement dans le container
RUN npm install -g @anthropic-ai/claude-code
RUN claude --version || true

# Répertoire de travail — sera rempli par git clone au démarrage
RUN mkdir -p /app/src
WORKDIR /app

# Entrypoint : clone le repo puis démarre l'app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000 22
ENTRYPOINT ["/entrypoint.sh"]
