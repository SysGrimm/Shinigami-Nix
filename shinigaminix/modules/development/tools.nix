{ config, lib, pkgs, ... }:

{
  # Development tools and utilities
  environment.systemPackages = with pkgs; [
    # Terminal and shell
    starship        # Cross-shell prompt
    zoxide          # Smart cd replacement
    eza             # Modern ls replacement
    bat             # Cat with syntax highlighting
    fd              # Find replacement
    ripgrep         # Grep replacement
    fzf             # Fuzzy finder
    zellij          # Terminal multiplexer
    tmux            # Terminal multiplexer
    
    # File management
    ranger          # Terminal file manager
    nnn             # Lightweight file manager
    tree            # Directory tree viewer
    
    # System monitoring
    btop            # Better top
    htop            # Interactive process viewer
    iotop           # I/O monitoring
    nethogs         # Network monitoring per process
    bandwhich       # Network utilization by process
    
    # Network tools
    nmap            # Network scanner
    wireshark       # Packet analyzer
    tcpdump         # Packet analyzer
    mtr             # Network diagnostic tool
    dig             # DNS lookup
    whois           # Domain information
    
    # Text processing
    jq              # JSON processor
    yq              # YAML/XML processor
    sed             # Stream editor
    awk             # Text processing
    
    # Archive and compression
    zip
    unzip
    p7zip
    unrar
    tar
    gzip
    xz
    
    # Image processing
    imagemagick     # Image manipulation
    ffmpeg          # Video/audio processing
    
    # PDF tools
    poppler_utils   # PDF utilities
    
    # Encryption and security
    gnupg           # GPG encryption
    age             # Modern encryption
    ssh-audit       # SSH security auditing
    
    # Benchmarking
    hyperfine       # Command-line benchmarking
    
    # Database tools
    sqlite          # SQLite database
    litecli         # SQLite CLI with autocomplete
    pgcli           # PostgreSQL CLI with autocomplete
    redis           # Redis CLI
    
    # Documentation
    man-pages       # Manual pages
    tldr            # Simplified man pages
    cheat           # Cheatsheets
    
    # Productivity
    calcurse        # Calendar and todo
    task            # Task management
    
    # Communication
    slack           # Team communication
    discord         # Communication
    signal-desktop  # Private messaging
    
    # Remote access
    remmina         # Remote desktop client
    
    # Backup and sync
    rsync           # File synchronization
    rclone          # Cloud storage sync
    
    # Web development
    caddy           # Web server
    
    # API testing
    insomnia        # API client
    
    # Virtualization
    qemu            # System emulator
    virt-manager    # VM management
    
    # Cloud tools
    awscli2         # AWS CLI
    google-cloud-sdk # Google Cloud SDK
    # azure-cli       # Azure CLI (temporarily disabled due to build issues)
    
    # Infrastructure as code
    terraform       # Infrastructure provisioning
    ansible         # Configuration management
    vagrant         # Development environments
    
    # Monitoring and logging
    loki            # Log aggregation
    promtail        # Log shipping
    
    # Performance profiling
    perf-tools      # Linux performance tools
    flamegraph      # Performance visualization
    
    # Security scanning
    trivy           # Container security scanner
    
    # Load testing
    hey             # HTTP load tester
    
    # Code analysis
    tokei           # Code statistics
    scc             # Code counter
    
    # Diff tools
    delta           # Better diff
    difftastic      # Structural diff
    
    # Process management
    supervisor      # Process control system
    
    # System information
    neofetch        # System information
    fastfetch       # System information (faster)
    
    # Hardware monitoring
    lm_sensors      # Hardware sensors
    
    # USB tools
    usbutils        # USB device utilities
    
    # Disk usage
    ncdu            # Disk usage analyzer
    dust            # Disk usage (du alternative)
    
    # Memory analysis
    valgrind        # Memory debugging
    
    # Hex editors
    hexedit         # Hex editor
    
    # Color tools
    colordiff       # Colorized diff
    
    # Time tracking
    watson          # Time tracking
    
    # Screen capture
    scrot           # Screenshot utility
    
    # System cleanup
    bleachbit       # System cleaner
    
    # Password management
    bitwarden       # Password manager
    
    # Note taking
    obsidian        # Knowledge management
    
    # Mind mapping
    freeplane       # Mind mapping
    
    # Drawing
    drawio          # Diagram editor
    
    # 3D modeling (for CAD work)
    freecad         # CAD software
    
    # Electronics
    kicad           # PCB design
    
    # Scientific computing
    octave          # MATLAB alternative
    
    # Statistics
    R               # Statistical computing
    
    # Machine learning
    python3Packages.jupyter # Jupyter notebooks
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.matplotlib
    python3Packages.scikit-learn
    
    # Game development
    godot_4         # Game engine
    
    # 3D graphics
    blender         # 3D creation suite
  ];

  # Enable services for development tools
  services = {
    # Enable locate database
    locate = {
      enable = true;
      locate = pkgs.mlocate;
      localuser = null;
    };
    
    # Enable man pages
    man.enable = true;
    
    # Enable documentation
    documentation.enable = true;
    documentation.man.enable = true;
    documentation.info.enable = true;
    documentation.doc.enable = true;
  };

  # Configure shell prompt (Starship)
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$python"
        "$character"
      ];
      
      directory = {
        style = "blue bold";
        truncation_length = 4;
        truncate_to_repo = false;
      };
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };
      
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };
      
      git_state = {
        format = "\([$state( $progress_current/$progress_total)]($style)\) ";
        style = "bright-black";
      };
      
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
      
      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };

  # Development environment variables
  environment.variables = {
    # Development tools
    STARSHIP_CONFIG = "/etc/starship.toml";
    
    # Performance
    MAKEFLAGS = "-j$(nproc)";
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "systemd"
        "colored-man-pages"
      ];
    };
    
    shellInit = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"
      
      # Initialize fzf
      eval "$(fzf --zsh)"
    '';
  };

  # Bash configuration (fallback)
  programs.bash = {
    enableCompletion = true;
    
    shellInit = ''
      # Initialize zoxide
      eval "$(zoxide init bash)"
      
      # Initialize fzf
      eval "$(fzf --bash)"
    '';
  };
}
