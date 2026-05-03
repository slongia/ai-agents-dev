# Use an official Python base image
FROM mcr.microsoft.com/vscode/devcontainers/python:3.11

# Install system packages and node (for Copilot CLI)
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ca-certificates build-essential \
    gnupg2 lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user (vscode user already exists in base image)
USER vscode
WORKDIR /workspace

# Ensure pip uses user site or system site inside container
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONUNBUFFERED=1

# Copy only devcontainer scripts (will be run in postCreate)
#COPY .devcontainer/post_create.sh /workspace/.devcontainer/post_create.sh
#RUN chmod +x /workspace/.devcontainer/post_create.sh

# Default command
CMD [ "sleep", "infinity" ]
