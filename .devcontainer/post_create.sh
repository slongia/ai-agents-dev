#!/usr/bin/env bash
set -e

# inside container: create venv (optional) and install Python deps
python -m venv .venv
. .venv/bin/activate

# Install Python dependencies (kept inside container)
pip install --upgrade pip
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
else
  pip install pydantic pydantic-ai openai aiohttp
fi

# Install GitHub Copilot CLI (inside container)
# Configure npm to use a user-local prefix to avoid permission errors
mkdir -p "${HOME}/.npm-global"
npm config set prefix "${HOME}/.npm-global"
export PATH="${HOME}/.npm-global/bin:${PATH}"
# Persist the PATH change for future shell sessions
echo 'export PATH="${HOME}/.npm-global/bin:${PATH}"' >> "${HOME}/.bashrc"
# package name maintained by GitHub: @githubnext/github-copilot-cli
npm install -g @githubnext/github-copilot-cli

# Install GitHub CLI (gh) for auth flows (optional)
# Use apt or the official install script if needed
# curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
# sudo apt update && sudo apt install gh -y

echo "Dev container post-create finished."
