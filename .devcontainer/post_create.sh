#!/usr/bin/env bash
set -e

echo "=== Starting devcontainer post-create setup ==="

# ---------------------------------------------------------------------------
# Python virtual environment
# ---------------------------------------------------------------------------
echo "--- Setting up Python venv ---"
python -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# ---------------------------------------------------------------------------
# npm global prefix for non-root user
# ---------------------------------------------------------------------------
echo "--- Configuring npm global prefix ---"
mkdir -p "${HOME}/.npm-global"
npm config set prefix "${HOME}/.npm-global"
export PATH="${HOME}/.npm-global/bin:${PATH}"

# ---------------------------------------------------------------------------
# Persist environment changes in .bashrc
# Using grep -qxF to avoid duplicate entries on container rebuilds
# ---------------------------------------------------------------------------
echo "--- Persisting shell environment in .bashrc ---"

# Put npm-global FIRST on PATH (before VS Code's injected paths)
PATH_LINE='export PATH="${HOME}/.npm-global/bin:${PATH}"'
grep -qxF "$PATH_LINE" "${HOME}/.bashrc" || echo "$PATH_LINE" >> "${HOME}/.bashrc"

# Auto-activate Python venv in new interactive shells
VENV_LINE='[ -f /workspace/.venv/bin/activate ] && source /workspace/.venv/bin/activate'
grep -qxF "$VENV_LINE" "${HOME}/.bashrc" || echo "$VENV_LINE" >> "${HOME}/.bashrc"

# ---------------------------------------------------------------------------
# Install GitHub Copilot CLI (official package)
# ---------------------------------------------------------------------------
echo "--- Installing GitHub Copilot CLI ---"
npm install -g @github/copilot

# Alias 'copilot' to the real binary so it wins over the VS Code Copilot Chat
# wrapper that lives at ~/.vscode-server/.../copilotCli/copilot.
# Aliases take precedence over PATH lookups in interactive shells.
ALIAS_LINE='alias copilot="${HOME}/.npm-global/bin/copilot"'
grep -qxF "$ALIAS_LINE" "${HOME}/.bashrc" || echo "$ALIAS_LINE" >> "${HOME}/.bashrc"

# ---------------------------------------------------------------------------
# Install GitHub Spec Kit (specify-cli) for spec-driven development
# ---------------------------------------------------------------------------
echo "--- Installing Spec Kit (from GitHub, not stale PyPI) ---"
pipx ensurepath
pipx install --force git+https://github.com/github/spec-kit.git

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "=== Dev container post-create finished ==="
echo ""
echo "Next steps:"
echo "  1. Open a NEW terminal (so .bashrc changes take effect)"
echo "  2. Run 'copilot --version' to verify the CLI is installed"
echo "  3. Run 'copilot' and authenticate with the device code"
echo "  4. Run 'specify check' to verify Spec Kit is ready"
echo "  5. This repo is already initialized for Spec Kit; do not rerun 'specify init' unless you intend to reinitialize it"
echo ""
