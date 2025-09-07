{ config, pkgs, lib, modulesPath, ... }:

let
  shinigaminixPlymouth = pkgs.callPackage ./../../assets/shinigaminix-plymouth.nix {};
in

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Custom ISO branding and boot configuration
  isoImage = {
    isoName = "ShinigamiNix-installer.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
    
    # Boot menu branding
    isoBaseName = lib.mkForce "ShinigamiNix";
    volumeID = "SHINIGAMI_NIX";
  };

  # Plymouth boot splash
  boot.plymouth = {
    enable = true;
    themePackages = [ shinigaminixPlymouth ];
    theme = "shinigaminix";
  };

  # Kernel parameters for better boot experience
  boot.kernelParams = [ 
    "quiet" 
    "splash" 
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  # Console settings for boot
  console = {
    font = "ter-128n";
    packages = [ pkgs.terminus_font ];
    earlySetup = true;
  };

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable Wayland compositor essentials
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Audio support
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  # Hardware support
  hardware.bluetooth.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Your requested applications
  environment.systemPackages = with pkgs; [
    # Desktop essentials
    kitty              # Modern GPU-accelerated terminal
    waybar             # Status bar for Wayland
    rofi-wayland       # Application launcher
    mako               # Notification daemon
    grim               # Screenshot tool
    slurp              # Screen selection
    wl-clipboard       # Clipboard utilities
    
    # Your applications
    brave
    vscode
    discord
    steam
    prismlauncher
    chiaki-ng
    
    # System tools
    tailscale
    git
    curl
    wget
    neovim
    networkmanagerapplet
    pavucontrol
    brightnessctl
    xfce.thunar
    
    # Additional Hyprland utilities
    wofi               # Alternative launcher (lighter than rofi)
    swww               # Wallpaper daemon for Wayland
    hyprpaper          # Wallpaper utility specifically for Hyprland
    hypridle           # Idle daemon for Hyprland
    hyprlock           # Screen locker for Hyprland
    wlogout            # Logout menu for Wayland
    swaynotificationcenter  # Notification center
  ];

  # Live session user (inherits from minimal CD)
  users.users.nixos.extraGroups = [ "video" "audio" ];
}
