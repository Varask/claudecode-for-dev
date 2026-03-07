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

# Installer Claude Code — accessible globalement (docker exec l'utilise en root)
RUN npm install -g @anthropic-ai/claude-code

# Vérifier que claude est bien dans le PATH
RUN claude --version || true

WORKDIR /app
COPY src/ /app/src/

WORKDIR /app/src
RUN npm install 2>/dev/null || true

EXPOSE 3000 22

CMD ["/bin/bash", "-c", "/usr/sbin/sshd && node index.js"]
