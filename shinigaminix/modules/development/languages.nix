{ config, lib, pkgs, ... }:

{
  # Programming languages and their ecosystems
  environment.systemPackages = with pkgs; [
    # Nix
    nil
    nixpkgs-fmt
    statix
    deadnix
    
    # Rust
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    
    # Go
    go
    gopls
    # gofmt  # gofmt comes with go package
    golangci-lint
    
    # Python
    python3Full
    python3Packages.pip
    python3Packages.virtualenv
    poetry
    pyright
    black
    ruff
    
    # JavaScript/TypeScript
    nodejs_20
    yarn
    pnpm
    bun
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
    
    # C/C++
    gcc
    clang
    cmake
    ninja
    gdb
    lldb
    clang-tools
    
    # Java
    openjdk21
    maven
    gradle
    
    # Kotlin
    kotlin
    
    # Scala
    scala
    sbt
    
    # C#/.NET
    dotnet-sdk_8
    
    # Lua
    lua
    luajit
    lua-language-server
    
    # Shell scripting
    shellcheck
    shfmt
    
    # Web development
    nodePackages.live-server
    nodePackages.http-server
    
    # Database tools
    sqlite
    postgresql
    redis
    
    # Container tools
    docker
    docker-compose
    podman
    buildah
    skopeo
    
    # Cloud tools
    kubectl
    helm
    terraform
    ansible
    
    # Version control
    git
    gh          # GitHub CLI
    gitui
    lazygit
    
    # API tools
    curl
    wget
    httpie
    postman
    
    # Documentation
    mdbook
    # gitbook-cli  # Package not available
    
    # Build tools
    gnumake
    cmake
    ninja
    meson
    
    # Package managers
    flatpak
    
    # Markup languages
    pandoc
    hugo
    zola
    
    # Data formats
    jq
    yq
    
    # Performance analysis
    valgrind
    perf-tools
    flamegraph
    
    # Monitoring
    prometheus
    grafana
  ];

  # Enable programming language services
  services = {
    # PostgreSQL for development
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      enableTCPIP = true;
    };
    
    # Redis for development
    redis = {
      servers.dev = {
        enable = true;
        port = 6379;
      };
    };
    
    # Docker for containerization
    docker.enable = true;
  };

  # Programming language environment variables
  environment.sessionVariables = {
    # Go
    GOPATH = "$HOME/.go";
    GOROOT = "${pkgs.go}/share/go";
    
    # Rust
    CARGO_HOME = "$HOME/.cargo";
    
    # Node.js
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    
    # Python
    PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH";
    
    # Java
    JAVA_HOME = "${pkgs.openjdk21}";
    
    # Editor
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # Pager
    PAGER = "less -R";
    
    # Browser for CLI tools
    BROWSER = "firefox";
  };

  # Shell aliases for development
  environment.shellAliases = {
    # Git shortcuts
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gd = "git diff";
    gco = "git checkout";
    gb = "git branch";
    
    # Docker shortcuts
    d = "docker";
    dc = "docker-compose";
    
    # Kubernetes shortcuts
    k = "kubectl";
    
    # Common commands
    ll = "ls -la";
    la = "ls -la";
    l = "ls -l";
    c = "clear";
    e = "nvim";
    
    # Directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    
    # System monitoring
    top = "btop";
    
    # File operations
    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";
    
    # Network
    ping = "ping -c 5";
    
    # Package management
    rebuild = "sudo nixos-rebuild switch --flake .";
    update = "nix flake update";
    
    # Development servers
    serve = "python -m http.server 8000";
    
    # JSON formatting
    json = "jq .";
  };

  # User groups for development
  users.users.reaper.extraGroups = [
    "docker"      # Docker access
    "postgres"    # PostgreSQL access
    "redis"       # Redis access
    "libvirtd"    # Virtualization
  ];

  # Fonts for programming
  fonts.packages = with pkgs; [
    source-code-pro
    fira-code
    fira-code-symbols
    jetbrains-mono
    cascadia-code
    nerd-fonts.fira-code nerd-fonts.jetbrains-mono
  ];

  # Enable nix-ld for running unpatched binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];
  };
}
