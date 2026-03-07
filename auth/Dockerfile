FROM node:22-slim

RUN apt-get update && apt-get install -y \
    curl bash git \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

RUN useradd -m -s /bin/bash claude
USER claude
WORKDIR /home/claude

COPY auth.sh /home/claude/auth.sh

ENTRYPOINT ["bash", "/home/claude/auth.sh"]
