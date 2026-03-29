# Shell Aliases

Quick reference for all shell aliases defined in `home.nix`.

## Modern CLI Replacements

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza` | Modern ls with colours and icons |
| `ll` | `eza -la --git` | Long list with git status |
| `lt` | `eza --tree` | Tree view |
| `cat` | `bat --paging=never --plain` | Syntax-highlighted cat |
| `ps` | `procs` | Better process list |
| `du` | `dust` | Intuitive disk usage |
| `df` | `duf` | Better disk free |
| `diff` | `difft` | Structural code diffs |
| `sed` | `sd` | Friendlier sed |

## Kubernetes

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `kx` | `kubectx` |
| `kn` | `kubens` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get svc` |
| `kgd` | `kubectl get deploy` |
| `kga` | `kubectl get all` |
| `kl` | `kubectl logs -f` |
| `kd` | `kubectl describe` |
| `kaf` | `kubectl apply -f` |
| `k8l` | source rancher-kubeconfig.sh |

## TUIs

| Alias | Command |
|-------|---------|
| `lg` | `lazygit` |
| `ld` | `lazydocker` |

## Java / Maven

| Alias | Command |
|-------|---------|
| `mvnci` | `mvn clean install` |
| `mvncp` | `mvn clean package` |
| `mvnt` | `mvn test` |

## Docker

| Alias | Command |
|-------|---------|
| `dps` | `docker ps` |
| `dimg` | `docker images` |

## Devbox

| Alias | Command |
|-------|---------|
| `devbox-update` | `~/mac-devbox/scripts/update.sh` |
| `devbox-setup` | `~/mac-devbox/scripts/setup.sh` |
