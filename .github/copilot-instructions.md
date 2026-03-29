# mac-devbox — Copilot Instructions

## Project overview

`mac-devbox` is a reproducible developer environment for macOS Apple Silicon.

- **CLI tools** (170+): managed by [Nix](https://nixos.org/) + [home-manager](https://github.com/nix-community/home-manager) via `home.nix`
- **GUI apps**: managed by [Homebrew Cask](https://formulae.brew.sh/cask/) via `Brewfile`
- **macOS system settings**: applied by `scripts/macos.sh` using `defaults write`
- **Bootstrap**: `install.sh` — runs on a fresh Mac, idempotent

Target platform: `aarch64-darwin` (Apple Silicon M-chip).

## Repository structure

```
mac-devbox/
├── flake.nix          # Nix flake — pins nixpkgs + home-manager (aarch64-darwin)
├── flake.lock         # Locked input versions (do not edit manually)
├── home.nix           # All Nix packages, shell config, aliases, env vars
├── Brewfile           # Homebrew Cask GUI apps and fonts
├── install.sh         # Bootstrap script
├── scripts/
│   ├── macos.sh       # macOS system defaults (defaults write)
│   ├── setup.sh       # Interactive: git identity, GitHub auth, credentials
│   ├── update.sh      # Update Homebrew + Nix + extras
│   ├── extras.sh      # Install/update Claude Code, Copilot CLI, Okteto
│   ├── clone-all-payroll-ce.sh
│   └── rancher-kubeconfig.sh
└── config/
    ├── maven-settings.xml
    ├── maven-toolchains.xml
    └── gradle.properties
```

## Conventions

- Commit messages follow **Conventional Commits** (see CONTRIBUTING.md)
- All scripts must pass `shellcheck`
- `install.sh` and all scripts in `scripts/` must be **idempotent**
- Credentials never go in this repo — stored in `~/.config/mac-devbox/credentials.env`

## Adding a Nix package

1. Find it on [search.nixos.org](https://search.nixos.org/packages) — filter by platform `aarch64-darwin`
2. Add to the appropriate section of `home.packages` in `home.nix`
3. Commit: `feat: add <package-name>`

## Adding a GUI app (Homebrew Cask)

1. Find it: `brew search --cask <name>`
2. Add a line to `Brewfile` with a comment explaining the app
3. Commit: `feat: add <app-name> to Brewfile`

## Updating Nix flake inputs

```bash
nix flake update
home-manager switch --flake .#default --impure
```

The `update-deps` workflow does this automatically every Monday.

## Key platform differences vs ce-devbox (WSL)

| Area | ce-devbox (WSL) | mac-devbox |
|------|----------------|------------|
| Nix system | `x86_64-linux` | `aarch64-darwin` |
| Home dir | `/home/user` | `/Users/user` |
| IDE profile hook | `~/.profile` | `~/.zprofile` |
| Docker creds | `wincred.exe` | `osxkeychain` |
| System packages | `apt` | Xcode CLT / Homebrew |
| GUI apps | not managed | Brewfile |

## Testing

Run locally before pushing:
```bash
shellcheck install.sh scripts/*.sh
nix flake check
nix build .#homeConfigurations.default.activationPackage --dry-run
```
