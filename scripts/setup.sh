#!/usr/bin/env bash
#
# setup.sh — interactive setup for a fresh environment.
#
# Run after install.sh to configure git identity, GitHub auth, and credentials.
# Designed to be idempotent — safe to re-run (e.g. to refresh an expired token).

set -euo pipefail

# ── Source Nix profile (needed when running from plain bash) ──────────
for f in "$HOME/.nix-profile/etc/profile.d/nix.sh" "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"; do
  # shellcheck source=/dev/null
  [[ -f "$f" ]] && . "$f"
done
export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:/opt/homebrew/bin:$PATH"

# ── Helpers ────────────────────────────────────────────────────────────

section() { echo -e "\n\033[1;32m[$1]\033[0m"; }
skip()    { echo "  skipped (already configured)"; }

# ── Git ────────────────────────────────────────────────────────────────

setup_git() {
  section "Git"

  CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)
  CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)

  if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
    echo "  name:  $CURRENT_NAME"
    echo "  email: $CURRENT_EMAIL"
    read -rp "  Reconfigure? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || return 0
  fi

  read -rp "  Full name: " name
  read -rp "  Email: " email

  git config --global user.name "$name"
  git config --global user.email "$email"
  echo "  done."
}

# ── GitHub authentication ─────────────────────────────────────────────

setup_gh() {
  section "GitHub"

  if ! command -v gh &>/dev/null; then
    echo "  gh not found — skipping"
    return 0
  fi

  if gh auth status &>/dev/null 2>&1; then
    echo "  authenticated as $(gh api user --jq '.login' 2>/dev/null || echo 'unknown')"
    echo "  token is valid"
  else
    echo "  token is expired or missing — re-authenticating..."
    gh auth login
  fi

  # Update Nix access token
  NIX_CONF="$HOME/.config/nix/nix.conf"
  if [ -f "$NIX_CONF" ]; then
    GH_TOKEN=$(gh auth token 2>/dev/null)
    if [ -n "$GH_TOKEN" ]; then
      if grep -q "access-tokens" "$NIX_CONF" 2>/dev/null; then
        # macOS sed requires empty string for in-place edit
        sed -i "" "s|^access-tokens.*|access-tokens = github.com=$GH_TOKEN|" "$NIX_CONF"
      else
        echo "access-tokens = github.com=$GH_TOKEN" >> "$NIX_CONF"
      fi
      echo "  nix access token updated"
    fi
  fi
}

# ── Nexus / Harbor credentials ────────────────────────────────────────

setup_nexus() {
  section "Nexus & Harbor"

  ENVFILE="$HOME/.config/mac-devbox/credentials.env"
  mkdir -p "$(dirname "$ENVFILE")"

  CURRENT_NEXUS=""
  CURRENT_HARBOR=""
  if [ -f "$ENVFILE" ]; then
    CURRENT_NEXUS=$(grep '^NEXUS_PASSWORD=' "$ENVFILE" 2>/dev/null | cut -d= -f2-)
    CURRENT_HARBOR=$(grep '^HARBOR_PASSWORD=' "$ENVFILE" 2>/dev/null | cut -d= -f2-)
  fi

  if [ -n "$CURRENT_NEXUS" ] && [ -n "$CURRENT_HARBOR" ]; then
    echo "  Nexus password:  ****$(echo "$CURRENT_NEXUS" | tail -c 5)"
    echo "  Harbor password: ****$(echo "$CURRENT_HARBOR" | tail -c 5)"
    read -rp "  Reconfigure? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || return 0
  fi

  echo "  Passwords are stored locally and used by Maven via \${env.NEXUS_PASSWORD}."
  echo "  Get the passwords from Azure Key Vault or ask a colleague."
  echo ""
  read -rsp "  Nexus password (nx-deployer): " nexus_pw; echo
  read -rsp "  Harbor password (robot\$harbor-cicd): " harbor_pw; echo

  cat > "$ENVFILE" <<EOF
NEXUS_PASSWORD=$nexus_pw
HARBOR_PASSWORD=$harbor_pw
EOF
  chmod 600 "$ENVFILE"
  echo "  done. Credentials saved to $ENVFILE"
}

# ── Add new sections above this line ───────────────────────────────────

main() {
  echo "=== Environment setup ==="

  setup_git
  setup_gh
  setup_nexus

  echo -e "\n\033[1;32mSetup complete.\033[0m"
}

main
