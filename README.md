# mac-devbox

> Full developer environment for macOS Apple Silicon — bootstrapped in one command.

Nix + home-manager manages 170+ CLI tools declaratively. Homebrew Cask handles GUI apps. A single `install.sh` sets everything up on a fresh Mac user account.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Bootstrap the Dev Environment](#bootstrap-the-dev-environment)
3. [Post-Install Setup](#post-install-setup)
4. [What's Included](#whats-included)
5. [Shell Aliases](#shell-aliases)
6. [Rancher Kubernetes](#rancher-kubernetes)
7. [Updating](#updating)
8. [How It Works](#how-it-works)
9. [Windows → Mac Transition Tips](#windows--mac-transition-tips)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **macOS** on Apple Silicon (M-chip, aarch64)
- A fresh user account (or an existing one — install is safe to run)
- Internet connection
- ~15 GB free disk space (Nix store + apps)

That's it. Homebrew, Nix, and all tools are installed automatically.

---

## Bootstrap the Dev Environment

Download the latest release and run the installer:

```bash
gh release download --repo <your-org>/mac-devbox -p 'mac-devbox.tar.gz' -D /tmp \
  && tar xzf /tmp/mac-devbox.tar.gz -C ~ \
  && ~/mac-devbox/install.sh
```

Or if you're cloning the repo directly:

```bash
git clone git@github.com:<your-org>/mac-devbox.git ~/mac-devbox
~/mac-devbox/install.sh
```

### What install.sh does (in order):

| Step | What happens |
|------|-------------|
| 1 | Checks for Xcode Command Line Tools (prompts to install if missing) |
| 2 | Installs Homebrew |
| 3 | Installs all GUI apps from `Brewfile` (Warp, IntelliJ, Brave, Bitwarden, Slack…) |
| 4 | Applies macOS system defaults (scroll direction, key repeat, Finder, Dock, screenshots) |
| 5 | Installs Nix via Determinate Systems installer |
| 6 | Enables Nix flakes |
| 7 | Activates home-manager (installs all 170+ CLI tools, configures Zsh, Git, etc.) |
| 8 | Installs extra tools (Claude Code, GitHub Copilot CLI, Okteto) |
| 9 | Sets Nix Zsh as default shell |
| 10 | Configures `~/.zprofile` for IDE login shell integration |
| 11 | Creates JDK symlink (`~/.jdks/openjdk-21`) for IntelliJ auto-detection |
| 12 | Installs Maven settings, toolchains, and Gradle properties |
| 13 | Configures Docker credential store (osxkeychain) |

---

## Post-Install Setup

After install completes, run the interactive setup script:

```bash
devbox-setup
# or: ~/mac-devbox/scripts/setup.sh
```

This configures:
- **Git identity** (name + email)
- **GitHub authentication** (`gh auth login`)
- **Nexus & Harbor credentials** (stored in `~/.config/mac-devbox/credentials.env`)

### Manual post-install steps

**Set Brave as default browser:**
`System Settings → Desktop & Dock → Default web browser → Brave`

**Enable Karabiner PC-style shortcuts** (Ctrl works like Cmd — for Windows muscle memory):
`Open Karabiner-Elements → Complex Modifications → Add rule → Import from Internet → search "PC-style shortcuts"`

**Enable CheatSheet** (hold ⌘ to see all shortcuts in any app):
`System Settings → Privacy & Security → Accessibility → CheatSheet → toggle on`

**IntelliJ IDEA — configure JDK:**
`File → Project Structure → SDKs → + → JDK → ~/. jdks/openjdk-21`

**Clone all CE repositories:**
```bash
~/mac-devbox/scripts/clone-all-payroll-ce.sh
```

---

## What's Included

See [PACKAGES.md](PACKAGES.md) for the full list.

**Highlights:**
- Java 21 (OpenJDK), Maven, Gradle, Spring Boot CLI
- Node.js 24, Python 3.13, Go
- kubectl, Helm, k9s, ArgoCD, Flux, and 15+ other K8s tools
- Docker (via Docker Desktop), lazydocker, dive, skopeo
- 13 AI coding assistants (Claude Code, Copilot, Aider, Gemini CLI…)
- Modern CLI replacements: `eza`, `bat`, `ripgrep`, `fd`, `zoxide`, `delta`…
- Full Zsh setup: Oh My Zsh, Starship (Tokyo Night), fzf, direnv, autosuggestions

**GUI apps (via Brewfile):**
Warp · IntelliJ IDEA Ultimate · VS Code · Brave · Bitwarden · Slack · Teams · Spark · Docker Desktop · Raycast · AltTab · Karabiner-Elements · CheatSheet · Stats · Ice · The Unarchiver · JetBrains Mono Nerd Font

---

## Shell Aliases

See [ALIASES.md](ALIASES.md) for the full list. Quick highlights:

```bash
ll          # eza -la --git
lg          # lazygit
ld          # lazydocker
k           # kubectl
kgp         # kubectl get pods
mvnci       # mvn clean install
devbox-update  # update everything
devbox-setup   # re-run setup (credentials, auth)
```

---

## Rancher Kubernetes

Fetch kubeconfigs for all Rancher-managed clusters:

```bash
k8l
# prompts for your Rancher bearer token
# sets KUBECONFIG automatically
```

---

## Updating

Update everything (Homebrew apps, Nix packages, extra tools) with one command:

```bash
devbox-update
# or: ~/mac-devbox/scripts/update.sh
```

This will:
1. Check for a new `mac-devbox` release and self-update if available
2. Run `brew update && brew upgrade`
3. Update Nix flake inputs
4. Rebuild the home-manager profile
5. Update Claude Code, Copilot CLI, Okteto
6. Garbage-collect old Nix generations

---

## How It Works

| File | Purpose |
|------|---------|
| `flake.nix` | Nix flake — pins nixpkgs + home-manager to `nixos-25.05` |
| `flake.lock` | Exact locked versions of all Nix inputs |
| `home.nix` | Declares all packages, shell config, aliases, env vars |
| `Brewfile` | GUI apps and fonts installed via Homebrew Cask |
| `install.sh` | Bootstrap: Homebrew → Nix → home-manager → extras |
| `scripts/macos.sh` | macOS system defaults (`defaults write` commands) |
| `scripts/setup.sh` | Interactive: git identity, GitHub auth, credentials |
| `scripts/update.sh` | Update everything in one command |
| `scripts/extras.sh` | Install/update Claude Code, Copilot CLI, Okteto |
| `config/` | Maven settings, toolchains, Gradle properties |

---

## Windows → Mac Transition Tips

Coming from Windows? These tools and tricks ease the switch:

### Installed automatically
| Tool | What it fixes |
|------|--------------|
| **Karabiner-Elements** | Ctrl+C/V/Z/X still works — remaps to Cmd under the hood |
| **CheatSheet** | Hold ⌘ in any app to see all shortcuts |
| **AltTab** | Alt+Tab switches windows (not just apps) like Windows |
| **Raycast** | Replaces Spotlight — much faster, has Bitwarden plugin |

### Key differences to know
| Windows | Mac equivalent |
|---------|---------------|
| `Ctrl+C/V/X/Z` | `Cmd+C/V/X/Z` (Karabiner handles the remapping) |
| `Alt+F4` | `Cmd+Q` (quit) or `Cmd+W` (close window) |
| `Windows key` | `Cmd key` |
| Task Manager | `Cmd+Space` → Activity Monitor (or Stats in menu bar) |
| File Explorer | Finder (`Cmd+Space` → Finder) |
| Right-click → Cut | Select file → `Cmd+C`, navigate, `Cmd+Option+V` to move |
| `Delete` key | `Fn+Delete` (forward delete) — regular Delete = Backspace |
| Scroll direction | Reversed by default — **macos.sh sets it to Windows-style** |
| `Ctrl+Alt+Delete` | Force quit: `Cmd+Option+Esc` |

---

## Troubleshooting

**`nix: command not found` after install**
```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

**home-manager activation fails with "file exists"**
```bash
home-manager switch --flake ~/mac-devbox#default --impure -b backup
```
The `-b backup` flag renames conflicting files instead of failing.

**IntelliJ can't find JDK**
```bash
ls -la ~/.jdks/openjdk-21   # should be a symlink
# If missing:
ln -sfn ~/.nix-profile/lib/openjdk ~/.jdks/openjdk-21
```

**Maven can't resolve dependencies (Nexus auth)**
```bash
devbox-setup   # re-enter Nexus/Harbor passwords
```

**Zsh feels slow on startup**
Check if `direnv` is loading a heavy `.envrc`. Run `direnv status` in the slow directory.

**Brew bundle fails on a cask**
Some casks require accepting a license or have other interactive requirements. Install manually:
```bash
brew install --cask <name>
```

**`chsh` fails — can't change shell**
```bash
sudo chsh -s ~/.nix-profile/bin/zsh $USER
# If that fails, use System Settings → Users & Groups → Advanced Options
```
