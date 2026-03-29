#!/usr/bin/env bash
#
# macos.sh — apply sensible macOS system defaults for a developer setup.
#
# Safe to re-run. Most settings take effect immediately;
# some require a logout/restart (noted inline).
#
# Run automatically by install.sh, or manually:
#   ~/mac-devbox/scripts/macos.sh

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC}    $*"; }
info() { echo -e "${CYAN}[INFO]${NC}  $*"; }

info "Applying macOS developer defaults..."

# ── Trackpad & Mouse ──────────────────────────────────────────────────────
# Disable "natural" (reversed) scrolling — use Windows/Linux direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
ok "Scroll direction: Windows-style (non-natural)"

# ── Keyboard ──────────────────────────────────────────────────────────────
# Fastest key repeat (hold a key → rapid repeat)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
ok "Key repeat: fast"

# Disable autocorrect, autocapitalise, smart dashes, smart quotes
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
ok "Autocorrect / autocapitalize / smart punctuation: disabled"

# Full keyboard access — tab through all UI controls, not just text fields
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
ok "Full keyboard access: enabled"

# ── Finder ────────────────────────────────────────────────────────────────
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
ok "File extensions: always visible"

# Show hidden files (dotfiles)
defaults write com.apple.finder AppleShowAllFiles -bool true
ok "Hidden files: visible"

# Show path bar and status bar at bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
ok "Finder: path bar + status bar enabled"

# Show full POSIX path in Finder title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
ok "Finder title: shows full path"

# Default to list view in Finder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
ok "Finder: default list view"

# Don't warn when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
ok "Finder: no extension-change warning"

# Don't write .DS_Store on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
ok "Finder: no .DS_Store on network/USB"

# Open new Finder windows in home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"
ok "Finder: new windows open in home folder"

# ── Dock ──────────────────────────────────────────────────────────────────
# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.1
defaults write com.apple.dock autohide-time-modifier -float 0.3
ok "Dock: auto-hide enabled (fast)"

# Smaller dock icons
defaults write com.apple.dock tilesize -int 48
ok "Dock: icon size 48px"

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false
ok "Dock: recent apps hidden"

# ── Screenshots ───────────────────────────────────────────────────────────
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
ok "Screenshots: saved to ~/Screenshots as PNG (no shadow)"

# ── Save dialogs ──────────────────────────────────────────────────────────
# Expand save panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
ok "Save panels: expanded by default"

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
ok "Save location: local disk (not iCloud)"

# ── Activity Monitor ──────────────────────────────────────────────────────
# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0
ok "Activity Monitor: show all processes"

# ── Restart affected services ─────────────────────────────────────────────
killall Finder    2>/dev/null || true
killall Dock      2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
echo -e "${GREEN}macOS defaults applied.${NC}"
echo "  Note: some changes (scroll direction, key repeat) take full effect after logout."
echo ""
