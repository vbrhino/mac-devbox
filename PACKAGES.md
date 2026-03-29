# Packages

All packages installed by mac-devbox, organized by category.

## Languages & Runtimes

| Package | Version | Notes |
|---------|---------|-------|
| OpenJDK | 21 (LTS) | via Nix |
| Node.js | 24 | includes npm + corepack |
| Python | 3.13 | includes pip + pipx |
| Go | latest | via Nix |
| C/C++ (clang) | Xcode CLT | via Xcode Command Line Tools |

## Build Tools

| Package | Notes |
|---------|-------|
| Maven | Nexus/Harbor repos pre-configured |
| Gradle | daemon + parallel + caching enabled |
| Spring Boot CLI | `spring` command |
| just | modern Makefile alternative |
| gnumake | `make` |
| pkg-config | |

## Kubernetes (15+ tools)

kubectl, Helm, Helmfile, k9s, ArgoCD, Flux, kubeseal, kustomize, krew,
kubeconform, popeye, stern, kubectx, kubens, kubie, kube-capacity,
kubeshark, velero, skaffold, chart-testing

## Containers

lazydocker, dive, skopeo, crane
+ Docker Desktop (via Brewfile) — includes docker CLI + compose

## Cloud & Infrastructure

Azure CLI, Terraform, TFLint

## Databases (clients)

psql (PostgreSQL), redis-cli, mongosh, mycli (MySQL TUI)

## Observability

prometheus (+ promtool), grafana-loki (+ logcli), k6, hey

## API & Debugging

httpie, xh, grpcurl, websocat

## Data / Messaging

kcat (Kafka CLI)

## Modern CLI Replacements

| Standard | Replacement | Alias |
|----------|-------------|-------|
| `grep` | ripgrep (`rg`) | — |
| `find` | fd | — |
| `cat` | bat | `cat` |
| `ls` | eza | `ls`, `ll`, `lt` |
| `cd` | zoxide | `z` |
| `sed` | sd | `sed` |
| `ps` | procs | `ps` |
| `du` | dust | `du` |
| `df` | duf | `df` |
| `diff` | difftastic | `diff` |
| `man` | tldr | `tldr` |
| `jq` (interactive) | jnv | — |

## AI CLI Tools (13+)

| Tool | Command | Notes |
|------|---------|-------|
| Claude Code | `claude` | Anthropic agentic coding assistant |
| GitHub Copilot | `gh copilot` | AI suggestions in terminal |
| Aider | `aider` | AI pair programmer with git integration |
| OpenAI Codex | `codex` | OpenAI's CLI agent |
| Google Gemini | `gemini` | Free tier (1000 req/day) |
| Goose | `goose` | Block's open-source MCP agent |
| OpenCode | `opencode` | Multi-provider open-source agent |
| aichat | `aichat` | All-in-one LLM CLI (20+ providers) |
| mods | `mods` | Pipe-friendly AI (`git diff \| mods`) |
| shell-gpt | `sgpt` | Quick shell command generation |
| llm | `llm` | Simon Willison's scriptable LLM tool |
| fabric | `fabric` | Crowdsourced AI prompt patterns |
| tgpt | `tgpt` | Zero-config AI chat (no API keys) |

## Git Tools

git (pre-configured), delta, lazygit, gh (GitHub CLI), git-crypt, act

## Shell Configuration

- **Shell:** Zsh with Oh My Zsh
- **Prompt:** Starship (Tokyo Night theme)
- **Plugins:** git, kubectl, docker, mvn, gradle, fzf, direnv, z
- **Extras:** autosuggestions, syntax highlighting, fzf, zoxide, direnv

## Security & Linting

trivy, gitleaks, hadolint, shellcheck, yamllint, mkcert

## Networking

dog, nmap, socat, bandwhich

## Terminal Utilities

tmux, vim, nano, mc (Midnight Commander), htop, btop, tree, watch, fzf

## GUI Apps (via Brewfile)

| App | Category |
|-----|---------|
| Warp | Terminal |
| IntelliJ IDEA Ultimate | IDE |
| Visual Studio Code | Editor |
| Brave Browser | Browser |
| Bitwarden | Password manager |
| Slack | Communication |
| Microsoft Teams | Communication |
| Spark Desktop | Mail |
| Docker Desktop | Containers |
| Raycast | Launcher / productivity |
| AltTab | Window switcher (Windows-style) |
| Karabiner-Elements | Key remapper (Windows→Mac shortcuts) |
| CheatSheet | Shortcut overlay (hold ⌘) |
| Stats | Menu bar system monitor |
| Ice | Menu bar organiser |
| The Unarchiver | Archive utility |
| JetBrains Mono Nerd Font | Font (Starship icons) |
