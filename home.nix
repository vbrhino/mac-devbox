{ config, lib, pkgs, ... }:

let
  # Detect username and home dir automatically so the same config works
  # for every colleague without edits.
  username = builtins.getEnv "USER";
  homeDir  = builtins.getEnv "HOME";
in
{
  home.username      = if username != "" then username else "user";
  home.homeDirectory = if homeDir  != "" then homeDir  else "/Users/user";
  home.stateVersion  = "24.11";   # do not change after first activation

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # ════════════════════════════════════════════════════════════════════════
  #  Packages
  # ════════════════════════════════════════════════════════════════════════
  home.packages = with pkgs; [

    # ── Core CLI ────────────────────────────────────────────────────────
    curl
    wget
    gnupg
    openssh
    jq
    yq-go
    tmux
    vim
    nano

    # ── Modern CLI replacements ─────────────────────────────────────────
    ripgrep             # rg  — faster grep
    fd                  # fd  — faster find
    bat                 # bat — cat with syntax highlighting
    eza                 # eza — modern ls
    fzf                 # fuzzy finder (ctrl-r, file picker)
    zoxide              # z   — smarter cd
    sd                  # sd  — friendlier sed
    procs               # procs — better ps
    dust                # dust — intuitive du
    duf                 # duf  — better df
    difftastic          # difft — structural code diffs
    tldr                # community-driven man pages
    jnv                 # interactive JSON navigator with jq
    mc                  # Midnight Commander file manager
    tree
    htop
    btop
    watch

    # ── Build toolchain ─────────────────────────────────────────────────
    # Note: C compiler (clang) and make are provided by Xcode Command Line Tools
    gnumake
    pkg-config
    just                # modern command runner (Justfile)

    # ── Java / Spring Boot ──────────────────────────────────────────────
    openjdk21
    maven
    gradle
    spring-boot-cli
    visualvm

    # ── Node.js / Frontend ──────────────────────────────────────────────
    nodejs_24           # includes npm + corepack — run `corepack enable` once

    # ── Python ──────────────────────────────────────────────────────────
    python313
    python313Packages.pip
    pipx
    pre-commit

    # ── Go ──────────────────────────────────────────────────────────────
    go

    # ── Kubernetes ──────────────────────────────────────────────────────
    kubectl
    kubernetes-helm
    helmfile            # declarative Helm releases
    chart-testing       # ct — lint & test Helm charts
    k9s
    argocd
    fluxcd              # GitOps toolkit
    kubeseal
    kustomize
    kubie
    krew
    kube-capacity
    kubeconform         # validate K8s manifests against schemas
    popeye              # K8s cluster sanitizer / best-practices
    stern               # multi-pod log tailing
    kubectx             # fast context/namespace switching
    kubeshark           # real-time K8s traffic viewer
    velero              # K8s backup & restore
    skaffold            # local K8s dev loop (build → push → deploy)

    # ── Docker / containers ─────────────────────────────────────────────
    # docker + docker-compose CLI are provided by Docker Desktop (Brewfile)
    lazydocker          # TUI for docker
    dive                # explore image layers
    skopeo              # inspect / copy images without pulling
    crane               # interact with container registries

    # ── Infrastructure / IaC ────────────────────────────────────────────
    terraform
    tflint

    # ── Cloud CLIs ──────────────────────────────────────────────────────
    azure-cli

    # ── Databases (clients only) ────────────────────────────────────────
    postgresql          # psql
    redis               # redis-cli
    mongosh             # MongoDB shell
    mycli               # MySQL/MariaDB TUI client

    # ── Observability ───────────────────────────────────────────────────
    prometheus          # includes promtool (validate prom rules/config)
    grafana-loki        # includes logcli (query Loki logs)
    k6                  # load testing (scriptable in JS)
    hey                 # quick HTTP load testing

    # ── API & debugging ─────────────────────────────────────────────────
    grpcurl             # curl for gRPC
    httpie              # user-friendly HTTP client
    xh                  # fast httpie alternative (Rust)
    websocat            # WebSocket client

    # ── Data / messaging ────────────────────────────────────────────────
    kcat                # Kafka CLI (formerly kafkacat)

    # ── Code quality, linting & security ────────────────────────────────
    cloc                # count lines of code
    tokei               # fast code statistics
    yamllint
    shellcheck          # shell script linter
    hadolint            # Dockerfile linter
    trivy               # vulnerability scanner (containers, IaC, SBOM)
    gitleaks            # scan git repos for secrets
    mkcert              # local trusted dev certificates

    # ── AI CLI tools ───────────────────────────────────────────────────
    # claude-code — installed via npm (extras.sh) to stay on latest version
    aider-chat          # AI pair programmer with deep git integration
    aichat              # Swiss-army knife LLM CLI (chat, RAG, shell assistant)
    mods                # pipe-friendly AI by Charmbracelet (`git diff | mods`)
    fabric-ai           # crowdsourced AI prompt patterns
    llm                 # Simon Willison's LLM CLI — scriptable, plugin ecosystem
    codex               # OpenAI's official CLI coding agent
    gemini-cli          # Google Gemini terminal agent — generous free tier
    goose-cli           # Block's open-source AI agent with MCP support
    shell-gpt           # quick shell command generation (`sgpt "find large files"`)
    tgpt                # zero-config AI chat — no API keys needed
    opencode            # open-source multi-provider AI coding agent

    # ── Git extras ──────────────────────────────────────────────────────
    delta               # syntax-highlighting pager for git
    gh                  # GitHub CLI
    lazygit             # TUI for git
    git-crypt           # transparent file encryption in git
    act                 # run GitHub Actions locally

    # ── Networking ──────────────────────────────────────────────────────
    # dig/nslookup are provided by macOS natively
    dog                 # modern DNS client
    nmap
    socat
    bandwhich           # per-process bandwidth monitor

    # ── Archive / misc ──────────────────────────────────────────────────
    unzip
    zip
    zstd
    xz
    bzip2
    file
    gettext             # provides envsubst
    openssl
  ];

  # ════════════════════════════════════════════════════════════════════════
  #  Program configs (home-manager modules)
  # ════════════════════════════════════════════════════════════════════════

  # ── Zsh + Oh My Zsh ──────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "";          # disabled — starship handles the prompt
      plugins = [
        "git"
        "kubectl"
        "docker"
        "mvn"
        "gradle"
        "fzf"
        "direnv"
        "z"
      ];
    };

    shellAliases = {
      # Modern replacements
      ls   = "eza";
      ll   = "eza -la --git";
      lt   = "eza --tree";
      cat  = "bat --paging=never --plain";
      ps   = "procs";
      du   = "dust";
      df   = "duf";
      diff = "difft";
      sed  = "sd";

      # Kubernetes
      k    = "kubectl";
      kx   = "kubectx";
      kn   = "kubens";
      kgp  = "kubectl get pods";
      kgs  = "kubectl get svc";
      kgd  = "kubectl get deploy";
      kga  = "kubectl get all";
      kl   = "kubectl logs -f";
      kd   = "kubectl describe";
      kaf  = "kubectl apply -f";

      # TUIs
      lg   = "lazygit";
      ld   = "lazydocker";

      # Java
      mvnci = "mvn clean install";
      mvncp = "mvn clean package";
      mvnt  = "mvn test";

      # Docker
      dps  = "docker ps";
      dimg = "docker images";

      # Rancher
      k8l  = "source ~/mac-devbox/scripts/rancher-kubeconfig.sh";

      # Devbox
      devbox-update = "~/mac-devbox/scripts/update.sh";
      devbox-setup  = "~/mac-devbox/scripts/setup.sh";
    };

    initContent = ''
      # Source Nexus/Harbor credentials for Maven
      if [ -f "$HOME/.config/mac-devbox/credentials.env" ]; then
        set -a
        source "$HOME/.config/mac-devbox/credentials.env"
        set +a
      fi

      # fzf / zoxide — skip when IntelliJ reads env via login shell
      if [ -z "''${INTELLIJ_ENVIRONMENT_READER:-}" ]; then
        # fzf key bindings (ctrl-r for history, ctrl-t for files)
        eval "$(fzf --zsh 2>/dev/null)"

        # zoxide (smarter cd)
        eval "$(zoxide init zsh)"
      fi

      # Coloured man pages (green/cyan hacker vibes)
      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;44;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;36m'

    '';
  };

  # ── Starship prompt ─────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {

      # Java is slow to start — raise from the 500ms default
      command_timeout = 2000;

      # ── Prompt format ──────────────────────────────────────────────────
      # Tokyo Night — two-line prompt with cool blue/purple tones
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nodejs"
        "$java"
        "$python"
        "$golang"
        "$rust"
        "$docker_context"
        "$kubernetes"
        "$cmd_duration"
        "$time"
        "$line_break"
        "$nix_shell"
        "$character"
      ];

      # ── OS ───────────────────────────────────────────────────────────
      os.disabled = true;

      # ── Directory ────────────────────────────────────────────────────
      directory = {
        style             = "fg:#e3e5e5 bg:#769ff0";
        format            = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
        read_only         = " ro";
        substitutions = {};
      };

      # ── Git ──────────────────────────────────────────────────────────
      git_branch = {
        symbol = "git:";
        style  = "bg:#394260";
        format = "[[ $symbol$branch ](fg:#769ff0 bg:#394260)]($style)";
      };
      git_status = {
        style  = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };

      # ── Languages ────────────────────────────────────────────────────
      nodejs = {
        symbol = "node:";
        style  = "bg:#212736";
        format = "[[ $symbol$version ](fg:#769ff0 bg:#212736)]($style)";
      };
      java = {
        symbol = "java:";
        style  = "bg:#212736";
        format = "[[ $symbol$version ](fg:#769ff0 bg:#212736)]($style)";
      };
      python = {
        symbol = "py:";
        style  = "bg:#212736";
        format = "[[ $symbol$version ](fg:#769ff0 bg:#212736)]($style)";
      };
      golang = {
        symbol = "go:";
        style  = "bg:#212736";
        format = "[[ $symbol$version ](fg:#769ff0 bg:#212736)]($style)";
      };
      rust = {
        symbol = "rs:";
        style  = "bg:#212736";
        format = "[[ $symbol$version ](fg:#769ff0 bg:#212736)]($style)";
      };

      # ── Containers & K8s ─────────────────────────────────────────────
      docker_context = {
        symbol = "docker:";
        style  = "bg:#1a1b26";
        format = "[[ $symbol$context ](fg:#769ff0 bg:#1a1b26)]($style)";
      };
      kubernetes = {
        disabled = false;
        symbol   = "k8s:";
        style    = "bg:#1a1b26";
        format   = "[[ $symbol$context(:$namespace) ](fg:#769ff0 bg:#1a1b26)]($style)";
      };

      # ── Cmd duration & time ──────────────────────────────────────────
      cmd_duration = {
        min_time = 2000;
        style    = "bg:#1d2230";
        format   = "[[ took $duration ](fg:#a0a9cb bg:#1d2230)]($style)";
      };
      time = {
        disabled    = false;
        time_format = "%R";
        style       = "bg:#1d2230";
        format   = "[[ $time ](fg:#a0a9cb bg:#1d2230)]($style)";
      };

      # ── Nix shell ────────────────────────────────────────────────────
      nix_shell = {
        symbol = "nix ";
        format = "[$symbol]($style) ";
        style  = "bold #769ff0";
      };

      # ── Line break & character ───────────────────────────────────────
      line_break.disabled = false;

      character = {
        success_symbol            = "[❯](bold #9ece6a)";
        error_symbol              = "[❯](bold #f7768e)";
        vimcmd_symbol             = "[❮](bold #9ece6a)";
        vimcmd_replace_one_symbol = "[❮](bold #bb9af7)";
        vimcmd_replace_symbol     = "[❮](bold #bb9af7)";
        vimcmd_visual_symbol      = "[❮](bold #e0af68)";
      };
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    # Set your own name/email by running: git config --global user.name "Your Name"
    # or let setup.sh prompt you interactively.

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = true;
      push.autoSetupRemote = true;
      merge.conflictstyle  = "diff3";
      diff.colorMoved      = "default";
      # Delta pager integration
      core.pager           = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate       = true;
      delta.line-numbers   = true;
      delta.side-by-side   = true;
      delta.syntax-theme   = "Dracula";
    };
  };

  # ── GitHub CLI ────────────────────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # ── lazygit ───────────────────────────────────────────────────────────
  programs.lazygit.enable = true;

  # ── direnv — auto-load .envrc per project ─────────────────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;   # fast cached nix shell loading
  };

  # ── bat (cat replacement) ─────────────────────────────────────────────
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "numbers,changes,header";
    };
  };

  # ── fzf (Catppuccin Mocha palette) ──────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      "--border=rounded"
      "--prompt='  '"
      "--pointer=' '"
    ];
  };

  # ════════════════════════════════════════════════════════════════════════
  #  Environment variables
  # ════════════════════════════════════════════════════════════════════════
  home.sessionVariables = {
    JAVA_HOME          = "${pkgs.openjdk21}";
    MAVEN_OPTS         = "-Xmx2g -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Dfile.encoding=UTF-8";
    EDITOR             = "vim";
    NPM_CONFIG_PREFIX  = "$HOME/.npm-global";
  };

  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
    "$HOME/.krew/bin"
    "$HOME/mac-devbox/scripts"
    "/opt/homebrew/bin"          # Homebrew on Apple Silicon
  ];
}
