FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git curl bash openssh-server vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd \
    && useradd -m -s /bin/bash dev \
    && echo "dev:dev" | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN npm install -g @anthropic-ai/claude-code

RUN claude --version || true

WORKDIR /app
COPY src/ /app/src/

WORKDIR /app/src
RUN npm install 2>/dev/null || true

EXPOSE 3001 22

CMD ["/bin/bash", "-c", "/usr/sbin/sshd && node index.js"]
