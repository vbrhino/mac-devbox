#!/usr/bin/env bash
#
# extras.sh — install/update tools not managed by Nix.
#
# Sourced by both install.sh and update.sh.
# Each function is idempotent — installs if missing, upgrades only when
# a newer version is available.

# Helper: get latest version tag from a GitHub repo via redirect (no API call).
_github_latest_version() {
  curl -fsSI "https://github.com/$1/releases/latest" 2>/dev/null \
    | grep -i '^location:' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

install_copilot_cli() {
  if command -v copilot &>/dev/null; then
    ok "GitHub Copilot CLI already installed"
    return 0
  fi

  info "Installing GitHub Copilot CLI..."
  curl -fsSL https://gh.io/copilot-install | bash
  ok "GitHub Copilot CLI installed"
}

install_gh_copilot() {
  if ! command -v gh &>/dev/null || ! gh auth status &>/dev/null 2>&1; then
    return 0
  fi

  if ! gh extension list 2>/dev/null | grep -q "gh-copilot"; then
    info "Installing gh copilot extension..."
    gh extension install github/gh-copilot
    ok "gh copilot extension installed"
  else
    info "Checking gh copilot extension for updates..."
    gh extension upgrade gh-copilot 2>/dev/null
    ok "gh copilot extension up to date"
  fi
}

install_claude_code() {
  local current

  if command -v claude &>/dev/null; then
    current=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    info "Updating Claude Code ($current → latest)..."
  else
    info "Installing Claude Code..."
  fi

  # Remove old npm-based installation if present
  if [ -x "$HOME/.npm-global/bin/claude" ]; then
    info "Removing old npm-based Claude Code installation..."
    npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
  fi

  curl -fsSL https://claude.ai/install.sh | bash
  ok "Claude Code up to date ($(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1))"
}

install_okteto() {
  local current latest

  if command -v okteto &>/dev/null; then
    current=$(okteto version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    latest=$(_github_latest_version "okteto/okteto")

    if [ -n "$current" ] && [ -n "$latest" ] && [ "$current" = "$latest" ]; then
      ok "Okteto CLI up to date ($current)"
      return 0
    fi

    if [ -n "$latest" ]; then
      info "Updating Okteto CLI: $current → $latest..."
    else
      info "Updating Okteto CLI..."
    fi
  else
    info "Installing Okteto CLI..."
  fi

  curl https://get.okteto.com -sSfL | sh
  ok "Okteto CLI up to date"
}
