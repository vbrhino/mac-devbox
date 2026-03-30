#!/usr/bin/env bash
# ============================================================================
#  Dev environment bootstrap — macOS Apple Silicon + Nix home-manager
#
#  Usage:
#    gh release download --repo <your-org>/mac-devbox -p 'mac-devbox.tar.gz' -D /tmp \
#      && tar xzf /tmp/mac-devbox.tar.gz -C ~ && ~/mac-devbox/install.sh
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "$0")" && pwd)}"

# ── 0. Xcode Command Line Tools ───────────────────────────────────────────
# Required for git, clang, make and native extension builds.
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  info "A dialog has appeared — click Install, then re-run this script when it finishes."
  exit 0
else
  ok "Xcode Command Line Tools already installed"
fi

# ── 1. Homebrew ──────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for the rest of this script (Apple Silicon path)
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
  eval "$(brew shellenv)"
fi

# ── 2. Install GUI apps & fonts via Brewfile ─────────────────────────────
info "Installing GUI apps and fonts via Brewfile..."
brew bundle --file="$FLAKE_DIR/Brewfile" --no-upgrade --no-lock || warn "Some casks failed — re-run: brew bundle --file=~/mac-devbox/Brewfile"
ok "Brewfile apps installed"

# ── 3. Apply macOS system defaults ──────────────────────────────────────
info "Applying macOS system defaults..."
bash "$FLAKE_DIR/scripts/macos.sh"
ok "macOS defaults applied"

# ── 4. Install Nix (multi-user) ───────────────────────────────────────────
if ! command -v nix &>/dev/null; then
  info "Installing Nix package manager..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || true
  . "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null || true
  ok "Nix installed"
else
  ok "Nix already installed"
fi

export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# Verify nix is actually usable in this shell (new terminal needed after first install)
if ! command -v nix &>/dev/null; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  Nix was installed but needs a new terminal to activate.    ║"
  echo "║                                                              ║"
  echo "║  ➜  Close this terminal, open a new one, then re-run:       ║"
  echo "║     bash ~/mac-devbox/install.sh                            ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  exit 0
fi

# ── 5. Enable flakes ──────────────────────────────────────────────────────
mkdir -p "$HOME/.config/nix"
if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
  ok "Flakes enabled"
fi

# ── 6. Configure GitHub token for Nix (avoids API rate limits) ────────────
if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
  GH_TOKEN=$(gh auth token 2>/dev/null)
  if [ -n "$GH_TOKEN" ] && ! grep -q "access-tokens" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "access-tokens = github.com=$GH_TOKEN" >> "$HOME/.config/nix/nix.conf"
    ok "GitHub token configured for Nix"
  fi
fi

# ── 7. First home-manager activation ──────────────────────────────────────
if [ ! -d "$FLAKE_DIR/.git" ]; then
  info "No .git directory found — initialising local git repo for Nix flakes..."
  git -C "$FLAKE_DIR" init -q
  git -C "$FLAKE_DIR" add -A
  git -C "$FLAKE_DIR" -c user.name="install" -c user.email="install@local" commit -qm "init"
  ok "Local git repo initialised"
fi

git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$FLAKE_DIR" \
  || git config --global --add safe.directory "$FLAKE_DIR"

info "Building and activating home-manager profile (this may take a while on first run)..."
nix run home-manager -- switch --flake "${FLAKE_DIR}#default" --impure --no-write-lock-file -b backup

ok "home-manager activated!"

__HM_SESS_VARS_SOURCED=
. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

# ── 8. Install extra tools (not managed by Nix) ───────────────────────────
. "$FLAKE_DIR/scripts/extras.sh"
install_copilot_cli
install_gh_copilot
install_okteto
install_claude_code

# ── 9. Set zsh as default shell ───────────────────────────────────────────
ZSH_PATH="$HOME/.nix-profile/bin/zsh"
if [ -x "$ZSH_PATH" ]; then
  CURRENT_SHELL=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
  if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    if ! grep -qF "$ZSH_PATH" /etc/shells 2>/dev/null; then
      info "Adding $ZSH_PATH to /etc/shells (needs sudo)..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    info "Changing default shell to zsh (needs sudo)..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    ok "Default shell set to zsh"
  else
    ok "Shell is already zsh"
  fi
fi

# ── 10. Ensure Nix profile is sourced for IDEs and login shells ───────────
# IntelliJ and other IDEs launch login shells which on macOS read ~/.zprofile.
ZPROFILE="$HOME/.zprofile"
NIX_SOURCE='
# Nix
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# home-manager session variables (JAVA_HOME, PATH, etc.)
if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi'

if ! grep -q "hm-session-vars" "$ZPROFILE" 2>/dev/null; then
  echo "$NIX_SOURCE" >> "$ZPROFILE"
  ok "Nix profile added to ~/.zprofile (for IDEs)"
fi

CRED_BLOCK='
# mac-devbox credentials (Nexus, Harbor)
if [ -f "$HOME/.config/mac-devbox/credentials.env" ]; then
  set -a
  . "$HOME/.config/mac-devbox/credentials.env"
  set +a
fi'

if ! grep -q "mac-devbox/credentials.env" "$ZPROFILE" 2>/dev/null; then
  echo "$CRED_BLOCK" >> "$ZPROFILE"
  ok "Credentials sourcing added to ~/.zprofile (for IDEs)"
fi

# ── 11. Configure JDK, Maven, and Gradle ──────────────────────────────────
# IntelliJ auto-scans ~/.jdks/ for JDKs
mkdir -p "$HOME/.jdks"
ln -sfn "$HOME/.nix-profile/lib/openjdk" "$HOME/.jdks/openjdk-21"
ok "JDK symlink created at ~/.jdks/openjdk-21"

# Maven: JDK location
echo 'JAVA_HOME="$HOME/.nix-profile/lib/openjdk"' > "$HOME/.mavenrc"

mkdir -p "$HOME/.m2"
if [ ! -f "$HOME/.m2/settings.xml" ]; then
  cp "$FLAKE_DIR/config/maven-settings.xml" "$HOME/.m2/settings.xml"
  ok "Maven settings.xml installed (~/.m2/settings.xml)"
else
  ok "Maven settings.xml already exists — skipped"
fi

if [ ! -f "$HOME/.m2/toolchains.xml" ]; then
  envsubst '$HOME' < "$FLAKE_DIR/config/maven-toolchains.xml" > "$HOME/.m2/toolchains.xml"
  ok "Maven toolchains.xml installed (~/.m2/toolchains.xml)"
else
  ok "Maven toolchains.xml already exists — skipped"
fi

mkdir -p "$HOME/.gradle"
if [ ! -f "$HOME/.gradle/gradle.properties" ]; then
  envsubst '$HOME' < "$FLAKE_DIR/config/gradle.properties" > "$HOME/.gradle/gradle.properties"
  ok "Gradle properties installed (~/.gradle/gradle.properties)"
elif ! grep -q "org.gradle.java.home" "$HOME/.gradle/gradle.properties" 2>/dev/null; then
  echo "org.gradle.java.home=$HOME/.nix-profile/lib/openjdk" >> "$HOME/.gradle/gradle.properties"
  ok "Gradle java.home appended (~/.gradle/gradle.properties)"
else
  ok "Gradle properties already configured — skipped"
fi

# ── 12. Docker credential store ───────────────────────────────────────────
# Docker Desktop on macOS manages credentials via the macOS keychain.
DOCKER_CONFIG_DIR="$HOME/.docker"
DOCKER_CONFIG_FILE="$DOCKER_CONFIG_DIR/config.json"
if [ ! -f "$DOCKER_CONFIG_FILE" ]; then
  mkdir -p "$DOCKER_CONFIG_DIR"
  cat > "$DOCKER_CONFIG_FILE" <<'EOF'
{
  "credsStore": "osxkeychain"
}
EOF
  ok "Docker config created (~/.docker/config.json → osxkeychain)"
else
  ok "Docker config already exists — skipped"
fi

# ── 13. Post-install reminders ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Install complete!                                        ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Next steps:"
echo "    1. Re-open your terminal (or run: exec zsh) to pick up zsh"
echo ""
echo "    2. Run setup script to configure git, GitHub auth & credentials:"
echo "         ${FLAKE_DIR}/scripts/setup.sh"
echo ""
echo "    3. Set Brave as default browser:"
echo "         System Settings → Desktop & Dock → Default web browser"
echo ""
echo "    4. Enable Karabiner PC-style shortcuts (Windows key muscle memory):"
echo "         Open Karabiner-Elements → Complex Modifications → Add rule"
echo "         → Import from Internet → search 'PC-style shortcuts'"
echo ""
echo "    5. Enable CheatSheet: System Settings → Privacy & Security"
echo "         → Accessibility → CheatSheet (toggle on)"
echo ""
