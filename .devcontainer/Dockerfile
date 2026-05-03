FROM mcr.microsoft.com/vscode/devcontainers/python:3.11

ARG DEBIAN_FRONTEND=noninteractive

# Base system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ca-certificates build-essential \
    gnupg2 lsb-release pipx \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 LTS (Copilot CLI requires Node 22+)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI (gh) - official apt repository
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

USER vscode
WORKDIR /workspace

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONUNBUFFERED=1

CMD [ "sleep", "infinity" ]