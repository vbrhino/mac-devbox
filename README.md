# mac-devbox

> Full developer environment for macOS Apple Silicon — bootstrapped in one command.

Open a terminal and run this. Everything else is automatic.

```bash
git clone https://github.com/vbrhino/mac-devbox.git ~/mac-devbox && ~/mac-devbox/install.sh
```

That's it. Get a coffee — first run takes ~15 minutes.

---

## What you get

- **170+ CLI tools** via Nix (Java 21, Node 24, Python 3.13, Go, Kubernetes, Docker, 13 AI assistants…)
- **17 GUI apps** via Homebrew (Warp, IntelliJ, Brave, Bitwarden, Slack, Teams, Spark, Raycast…)
- **macOS tuned** for developers (scroll direction, key repeat, Dock, Finder, screenshots)
- **Windows → Mac helpers** (Karabiner remaps Ctrl shortcuts, AltTab, CheatSheet)
- **Zsh** with Oh My Zsh, Starship prompt, fzf, zoxide, autosuggestions

---

## Prerequisites

- Mac with Apple Silicon (M1/M2/M3/M4)
- Internet connection
- ~15 GB free disk space

Nothing else. Homebrew, Nix, Xcode CLT — all installed automatically.

---

## Step-by-step

### 1. Run the installer

```bash
git clone https://github.com/vbrhino/mac-devbox.git ~/mac-devbox && ~/mac-devbox/install.sh
```

> **Note:** If Xcode Command Line Tools aren't installed yet, a dialog will appear. Click **Install**, wait for it to finish, then re-run the command above.

The installer will:
1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew
3. Install all GUI apps from `Brewfile`
4. Apply macOS system defaults (scroll direction, Dock, Finder, screenshots…)
5. Install Nix
6. Install all 170+ CLI tools via home-manager
7. Install Claude Code, GitHub Copilot CLI, Okteto
8. Set Zsh as your default shell
9. Configure Maven, Gradle, and JDK symlink for IntelliJ

### 2. Run the setup script

After the installer finishes, run:

```bash
devbox-setup
```

This will ask for:
- Your **name and email** (for git commits)
- **GitHub login** (`gh auth login` — opens browser)
- **Nexus & Harbor passwords** (for Maven builds — get from Azure Key Vault or a colleague)

### 3. Re-open your terminal

Close and reopen your terminal (or run `exec zsh`) to load the new shell.

### 4. One-time manual steps

**Set Brave as default browser:**
`System Settings → Desktop & Dock → Default web browser → Brave`

**Enable Karabiner PC-style shortcuts** so Ctrl+C/V/Z/X still works like on Windows:
`Open Karabiner-Elements → Complex Modifications → Add rule → Import from Internet → search "PC-style shortcuts" → enable`

**Enable CheatSheet** (hold ⌘ in any app to see all shortcuts):
`System Settings → Privacy & Security → Accessibility → CheatSheet → toggle on`

**Configure IntelliJ JDK:**
`File → Project Structure → SDKs → + → JDK → ~/.jdks/openjdk-21`

**Clone all CE repositories:**
```bash
~/mac-devbox/scripts/clone-all-payroll-ce.sh
```

---

## Keeping everything up to date

One command updates Homebrew apps, Nix packages, and extra tools:

```bash
devbox-update
```

---

## What's included

See [PACKAGES.md](PACKAGES.md) for the full list.

**Selected highlights:**

| Category | Tools |
|----------|-------|
| Java | OpenJDK 21, Maven, Gradle, Spring Boot CLI, VisualVM |
| Frontend | Node.js 24, npm, corepack |
| Python | 3.13, pip, pipx, pre-commit |
| Kubernetes | kubectl, Helm, k9s, ArgoCD, Flux, stern, kubectx, k9s… |
| Containers | Docker Desktop, lazydocker, dive, skopeo, crane |
| AI | Claude Code, Copilot, Aider, Gemini CLI, Codex, Goose… |
| Git | delta, lazygit, gh, git-crypt, act |
| Modern CLI | eza, bat, ripgrep, fd, zoxide, fzf, delta… |

---

## Shell aliases

See [ALIASES.md](ALIASES.md). Quick highlights:

```bash
ll            # eza -la --git
lg            # lazygit
ld            # lazydocker
k             # kubectl
kgp           # kubectl get pods
mvnci         # mvn clean install
devbox-update # update everything
devbox-setup  # re-run setup
k8l           # fetch Rancher kubeconfigs
```

---

## Rancher Kubernetes

```bash
k8l   # prompts for Rancher bearer token, sets KUBECONFIG automatically
```

---

## Windows → Mac cheat sheet

| Windows | Mac |
|---------|-----|
| `Ctrl+C/V/X/Z` | Handled by Karabiner ✅ |
| `Alt+Tab` (window-level) | `Alt+Tab` via AltTab app ✅ |
| Task Manager | `Cmd+Space` → Activity Monitor, or Stats in menu bar |
| File Explorer | Finder |
| Right-click → Cut | Select → `Cmd+C`, then `Cmd+Option+V` to move |
| `Delete` (forward) | `Fn+Delete` |
| `Alt+F4` | `Cmd+Q` (quit) / `Cmd+W` (close window) |
| Hold ⌘ | Shows all shortcuts for current app (CheatSheet) ✅ |

---

## How it works

| File | Purpose |
|------|---------|
| `flake.nix` | Pins nixpkgs + home-manager versions (aarch64-darwin) |
| `home.nix` | Declares all CLI packages, shell config, aliases, env vars |
| `Brewfile` | GUI apps and fonts via Homebrew Cask |
| `install.sh` | Bootstrap — runs once on a fresh Mac |
| `scripts/macos.sh` | macOS system defaults |
| `scripts/setup.sh` | Interactive: git, GitHub auth, credentials |
| `scripts/update.sh` | Updates everything |
| `scripts/extras.sh` | Claude Code, Copilot CLI, Okteto |
| `config/` | Maven settings, toolchains, Gradle properties |

---

## Troubleshooting

**Xcode dialog appeared and disappeared — installer didn't continue**
Re-run `~/mac-devbox/install.sh` after Xcode CLT finishes installing.

**`nix: command not found` after install**
```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
exec zsh
```

**home-manager activation fails with "file exists"**
```bash
home-manager switch --flake ~/mac-devbox#default --impure -b backup
```

**IntelliJ can't find JDK**
```bash
ln -sfn ~/.nix-profile/lib/openjdk ~/.jdks/openjdk-21
```
Then in IntelliJ: `File → Project Structure → SDKs → + → ~/.jdks/openjdk-21`

**Maven can't resolve dependencies**
```bash
devbox-setup   # re-enter Nexus/Harbor passwords
```

**Homebrew cask fails interactively**
```bash
brew install --cask <name>
```

**`chsh` fails**
`System Settings → Users & Groups` → right-click your user → `Advanced Options` → set shell to `~/.nix-profile/bin/zsh`

