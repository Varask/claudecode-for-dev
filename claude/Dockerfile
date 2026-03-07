FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git curl bash openssh-client \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

RUN useradd -m -s /bin/bash claude \
    && usermod -aG docker claude 2>/dev/null || true

USER claude
WORKDIR /home/claude

ENTRYPOINT ["claude"]
CMD ["--help"]
