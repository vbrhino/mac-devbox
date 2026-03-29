# Contributing

mac-devbox uses **Conventional Commits** for automatic semantic versioning.
Every push to `main` is evaluated — a new release is created only when relevant commits are found.

## Commit Format

```
<type>(<scope>): <description>
```

## Commit Types & Version Bumps

| Type | Version bump | When to use |
|------|-------------|-------------|
| `feat:` | **minor** (1.x.0) | New tool, new script, new alias |
| `fix:` | **patch** (1.0.x) | Bug fix in a script |
| `feat!:` or `BREAKING CHANGE` | **major** (x.0.0) | Incompatible change (e.g. renamed script) |
| `chore:` | none | Maintenance, dependency updates |
| `docs:` | none | Documentation only |
| `refactor:` | none | Code cleanup without behaviour change |
| `ci:` | none | GitHub Actions changes |

## Examples

```bash
git commit -m "feat: add Warp terminal to Brewfile"
git commit -m "fix: correct sed -i syntax for macOS in setup.sh"
git commit -m "chore: update nix flake inputs"
git commit -m "docs: add troubleshooting for JDK symlink"
git commit -m "feat!: rename credentials dir from ce-devbox to mac-devbox"
```

## What Happens on Push

1. GitHub Actions evaluates all commits since the last tag
2. Determines the highest bump (`feat!` > `feat` > `fix`)
3. Tags the new version (`vMAJOR.MINOR.PATCH`)
4. Builds `mac-devbox.tar.gz` and creates a GitHub Release

## Adding a Package (Nix)

1. Find the package name on [search.nixos.org](https://search.nixos.org/packages)
2. Add it to `home.packages` in `home.nix`
3. Commit: `feat: add <package-name>`

## Adding a GUI App (Homebrew)

1. Find the cask name: `brew search --cask <name>`
2. Add it to `Brewfile`
3. Commit: `feat: add <app-name> to Brewfile`

## Updating Tool Versions

Nix pins are updated automatically every Monday via the `update-deps` workflow.
For manual updates: `nix flake update` then test with `home-manager switch --flake .#default --impure`.
