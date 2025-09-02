{ config, lib, pkgs, inputs, pkgs-stable, ... }:

{
  imports = [
    # Hardware modules
    ../../modules/hardware/framework13.nix
    
    # Desktop environment
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/rice.nix
    
    # Development environment
    ../../modules/development/editors.nix
    ../../modules/development/languages.nix
    ../../modules/development/tools.nix
    
    # Gaming
    ../../modules/gaming/steam.nix
    ../../modules/gaming/graphics.nix
    
    # Overlays
    ../../overlays
  ];

  # System information
  system.stateVersion = "24.05";
  
  # Hostname
  networking.hostName = "aetherbook";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false; # Disable wpa_supplicant

  # Time zone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Kernel
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Kernel parameters for Framework 13
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
      # Power management
      "intel_pstate=active"
      "i915.enable_guc=2"
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
    ];
    
    # Enable firmware updates
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
  
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  # Audio
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  # Users
  users.users.reaper = {
    isNormalUser = true;
    description = "reaper";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "audio" 
      "video" 
      "input" 
      "plugdev" 
      "storage"
      "libvirtd"
      "docker"
      "gamemode"
    ];
    shell = pkgs.zsh;
  };

  # Sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable dconf for GTK settings
  programs.dconf.enable = true;

  # XDG portal configuration handled by hyprland module

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      nerdfonts
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Code" ];
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # System utilities
    wget
    curl
    git
    vim
    neovim
    htop
    btop
    tree
    unzip
    zip
    file
    which
    lshw
    usbutils
    pciutils
    
    # Network tools
    networkmanagerapplet
    wireguard-tools
    
    # Development
    gcc
    gnumake
    pkg-config
    
    # Audio/Video
    pavucontrol
    playerctl
    
    # File management
    ranger
    nautilus
    
    # Terminal
    alacritty
    kitty
    
    # Browsers
    firefox
    chromium
  ];

  # Services
  services = {
    # SSH
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    
    # Printing
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    
    # Location for redshift/gammastep
    geoclue2.enable = true;
    
    # Flatpak
    flatpak.enable = true;
  };

  # Virtualization
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };
  
  programs.virt-manager.enable = true;

  # Enable nix flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
