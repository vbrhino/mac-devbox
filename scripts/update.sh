#!/usr/bin/env bash
#
# update.sh — update Homebrew apps and Nix dev environment.
#
# Designed to be idempotent — safe to re-run anytime.

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

# ── Source Nix profile (needed when running from plain bash) ──────────
for f in "$HOME/.nix-profile/etc/profile.d/nix.sh" "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"; do
  # shellcheck source=/dev/null
  [[ -f "$f" ]] && . "$f"
done
export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:/opt/homebrew/bin:$PATH"

FLAKE_DIR="${FLAKE_DIR:-$HOME/mac-devbox}"
REPO="vbrhino/mac-devbox"

# ── 1. Check for new mac-devbox release ──────────────────────────────
update_mac_devbox() {
  if ! command -v gh &>/dev/null || ! gh auth status &>/dev/null 2>&1; then
    warn "gh not authenticated — skipping mac-devbox update check"
    return 0
  fi

  LATEST_TAG=$(gh release view --repo "$REPO" --json tagName --jq '.tagName' 2>/dev/null || true)
  if [ -z "$LATEST_TAG" ]; then
    warn "Could not fetch latest release — skipping mac-devbox update check"
    return 0
  fi

  CURRENT_TAG=""
  if [ -f "$FLAKE_DIR/.version" ]; then
    CURRENT_TAG=$(cat "$FLAKE_DIR/.version")
  fi

  if [ "$CURRENT_TAG" = "$LATEST_TAG" ]; then
    ok "mac-devbox is up to date ($CURRENT_TAG)"
    return 0
  fi

  info "New mac-devbox release available: ${CURRENT_TAG:-none} → $LATEST_TAG"
  info "Downloading $LATEST_TAG..."

  gh release download --repo "$REPO" -p 'mac-devbox.tar.gz' -D /tmp --clobber
  tar xzf /tmp/mac-devbox.tar.gz -C "$HOME"
  rm -f /tmp/mac-devbox.tar.gz

  if [ ! -d "$FLAKE_DIR/.git" ]; then
    git -C "$FLAKE_DIR" init -q
    git -C "$FLAKE_DIR" add -A
    git -C "$FLAKE_DIR" -c user.name="update" -c user.email="update@local" commit -qm "update to $LATEST_TAG"
  else
    git -C "$FLAKE_DIR" add -A
    git -C "$FLAKE_DIR" -c user.name="update" -c user.email="update@local" commit -qm "update to $LATEST_TAG" --allow-empty
  fi

  echo "$LATEST_TAG" > "$FLAKE_DIR/.version"
  ok "mac-devbox updated to $LATEST_TAG"

  info "Restarting update with new version..."
  export MAC_DEVBOX_UPDATED=true
  exec "$FLAKE_DIR/scripts/update.sh"
}

if [ "${MAC_DEVBOX_UPDATED:-}" = "true" ]; then
  ok "mac-devbox already updated in this run"
else
  info "Checking for mac-devbox updates..."
  update_mac_devbox
fi

# ── 2. Homebrew updates ───────────────────────────────────────────────
info "Updating Homebrew..."
brew update
brew upgrade
brew bundle --file="$FLAKE_DIR/Brewfile" --no-upgrade
ok "Homebrew up to date"

# ── 3. Update Nix flake inputs ────────────────────────────────────────
info "Updating Nix flake inputs..."
nix flake update --flake "$FLAKE_DIR"
ok "Flake inputs updated"

# ── 4. Rebuild home-manager profile ──────────────────────────────────
info "Rebuilding home-manager profile..."
home-manager switch --flake "${FLAKE_DIR}#default" --impure -b backup
ok "home-manager profile rebuilt"

__HM_SESS_VARS_SOURCED=
. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

# ── 5. Update extra tools (not managed by Nix) ───────────────────────
. "$FLAKE_DIR/scripts/extras.sh"
install_copilot_cli
install_gh_copilot
install_okteto
install_claude_code

# ── 6. Garbage collect old Nix generations ────────────────────────────
info "Collecting Nix garbage (old generations)..."
nix-collect-garbage -d
ok "Nix garbage collected"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  All updates complete!                                    ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
