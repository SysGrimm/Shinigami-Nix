{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/desktop/hyprland.nix
  ];

  # Allow unfree packages (needed for firmware and some packages)
  nixpkgs.config.allowUnfree = true;

  # Allow unfree packages (needed for some firmware and drivers)
  nixpkgs.config.allowUnfree = true;

  # Override minimal config for our desktop environment
  services.xserver.enable = lib.mkForce false;  # We're using Wayland
  
  # Enable Wayland and Hyprland
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
  };

  # XDG portal for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Wayland environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Make this ISO hardware-agnostic
  isoImage = {
    isoName = "nixos-hyprland-installer.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  environment.systemPackages = with pkgs; [
    # Core desktop tools
    foot  # Terminal
    rofi-wayland  # Application launcher
    waybar  # Status bar
    mako  # Notifications
    grim  # Screenshots
    slurp  # Screen selection
    wl-clipboard  # Clipboard
    
    # Applications
    firefox  # Use Firefox instead of Brave for better compatibility
    vscode
    discord
    steam
    prismlauncher
    
    # System tools
    tailscale
    networkmanagerapplet
    pavucontrol
    brightnessctl
    
    # File management
    xfce.thunar
    xfce.thunar-volman
  ];

  # Enable Tailscale service
  services.tailscale.enable = true;

  # Hardware support
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  
  # Graphics and gaming support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Audio via PipeWire (conflicts resolved)
  sound.enable = false;  # Disable ALSA
  hardware.pulseaudio.enable = false;  # Disable PulseAudio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Display manager for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Network
  networking.networkmanager.enable = true;

  # Set a default user for live session
  users.users.nixos = {
    isNormalUser = true;
    password = "nixos";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Allow sudo without password for live user
  security.sudo.wheelNeedsPassword = false;

  # Set a default locale and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";
}
